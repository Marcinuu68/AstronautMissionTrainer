extends Node3D
# International Space Station orbiting its PARENT node (the Earth Node3D).
# Self-contained: no other orbit script is needed.
# Untested: tweak values in the Inspector.
#
#   Earth (Node3D, no script)
#   ├── Planet
#   └── ISSOrbit  <- this script
#       └── iss   <- the iss.glb model (drag the file here)

enum Mode { FACE_EARTH, SPIN, NONE }

@export var orbit_radius := 12         # Earth radius is 6.4, so keep this above ~8 to clear the model
@export var orbit_period_seconds := 20   # seconds for one lap (the real ISS takes about 92 minutes)
@export_range(-180.0, 180.0) var inclination_deg := 51.6   # the real ISS tilt
@export_range(-180.0, 180.0) var raan_deg := 0.0           # turns the tilted orbit around Earth
@export var start_angle_deg := 0.0

@export var model_scale := 0.02               # applied to the model child; raise if the ISS is too small
@export var mode: Mode = Mode.FACE_EARTH      # FACE_EARTH, SPIN or NONE
@export var spin_speed_deg := 15.0            # used when mode = SPIN

@export var draw_orbit_line := false
@export var orbit_line_color := Color(0.7, 0.9, 1.0, 0.3)

var _angle := 0.0


func _ready() -> void:
	# Scale the model(s) sitting under this node, so you don't have to scale it by hand.
	for child in get_children():
		if child is Node3D:
			(child as Node3D).scale = Vector3.ONE * model_scale

	_angle = deg_to_rad(start_angle_deg)
	position = _orbit_point(_angle)
	if draw_orbit_line:
		_build_orbit_line()


func _process(delta: float) -> void:
	var speed := TAU / maxf(orbit_period_seconds, 0.001)   # radians per second
	_angle = fposmod(_angle + speed * delta, TAU)
	position = _orbit_point(_angle)

	match mode:
		Mode.FACE_EARTH:
			_face_parent()
		Mode.SPIN:
			rotate_object_local(Vector3.UP, deg_to_rad(spin_speed_deg) * delta)


# A point on the circular orbit: flat in XZ, then tilted and turned.
func _orbit_point(angle: float) -> Vector3:
	var p := Vector3(cos(angle), 0.0, -sin(angle)) * orbit_radius
	p = p.rotated(Vector3.RIGHT, deg_to_rad(inclination_deg))
	p = p.rotated(Vector3.UP, deg_to_rad(raan_deg))
	return p


# Point this node's front (-Z) at Earth.
func _face_parent() -> void:
	var parent := get_parent() as Node3D
	if parent == null:
		return
	var target := parent.global_position
	var dir := target - global_position
	if dir.length() < 0.001:
		return
	var up := Vector3.UP
	if absf(dir.normalized().dot(Vector3.UP)) > 0.99:
		up = Vector3.RIGHT
	look_at(target, up)


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
