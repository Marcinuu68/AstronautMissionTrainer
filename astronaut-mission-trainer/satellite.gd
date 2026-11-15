extends Node3D
# A satellite that circles its PARENT node (put it beside the Earth sphere, under the "Earth" Node3D).
# Self-contained: no orbit.gd needed. Put your .glb model as a child of this node.
# Untested: tweak values in the Inspector.
#
#   Earth (Node3D, no script)
#   ├── Planet
#   └── Sat  <- this script
#       └── cloudsat (.glb)

enum Mode { FACE_EARTH, SPIN, NONE }

@export var orbit_radius := 12.0              # must be bigger than Earth's radius + model size
@export var orbit_speed_deg := 18          # degrees per second (36 = one lap in 10 s)
@export_range(-180.0, 180.0) var inclination_deg := 51.6   # tilts the orbit (0 = flat)
@export_range(-180.0, 180.0) var raan_deg := 0.0          # turns the tilted orbit around Earth
@export var start_angle_deg := 0.0            # where on the orbit it begins

@export var mode: Mode = Mode.FACE_EARTH      # FACE_EARTH, SPIN or NONE
@export var spin_speed_deg := 20.0            # used when mode = SPIN

@export var draw_orbit_line := true
@export var orbit_line_color := Color(0.7, 0.8, 1.0, 0.35)

var _angle := 0.0


func _ready() -> void:
	_angle = deg_to_rad(start_angle_deg)
	position = _orbit_point(_angle)
	if draw_orbit_line:
		_build_orbit_line()


func _process(delta: float) -> void:
	_angle = fposmod(_angle + deg_to_rad(orbit_speed_deg) * delta, TAU)
	position = _orbit_point(_angle)

	match mode:
		Mode.FACE_EARTH:
			_face_parent()
		Mode.SPIN:
			rotate_object_local(Vector3.UP, deg_to_rad(spin_speed_deg) * delta)


# A point on the circular orbit, flat in the XZ plane, then tilted and turned.
func _orbit_point(angle: float) -> Vector3:
	var p := Vector3(cos(angle), 0.0, -sin(angle)) * orbit_radius
	p = p.rotated(Vector3.RIGHT, deg_to_rad(inclination_deg))   # tilt
	p = p.rotated(Vector3.UP, deg_to_rad(raan_deg))             # turn around Earth
	return p


# Point this node's front (-Z) at the parent (Earth).
func _face_parent() -> void:
	var parent := get_parent() as Node3D
	if parent == null:
		return
	var target := parent.global_position
	var dir := target - global_position
	if dir.length() < 0.001:
		return
	# look_at fails if the direction is parallel to "up", so switch up-vector in that case
	var up := Vector3.UP
	if absf(dir.normalized().dot(Vector3.UP)) > 0.99:
		up = Vector3.RIGHT
	look_at(target, up)


# Draw the orbit path once, as a child of the parent so it follows it.
func _build_orbit_line() -> void:
	var mesh := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = orbit_line_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var steps := 128
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in steps + 1:
		mesh.surface_add_vertex(_orbit_point(TAU * float(i) / float(steps)))
	mesh.surface_end()

	var line := MeshInstance3D.new()
	line.mesh = mesh
	get_parent().add_child.call_deferred(line)
