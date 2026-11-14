extends Node3D
# Keplerian orbit, ported from NASA's "Elliptical Orbit Simulator" (R / rgl tutorial).
# Attach to a Node3D that is a CHILD of the planet's parent node (beside the planet).
# The planet sits at the origin of its own local space; this node orbits it.

@export var semi_major_axis := 30.0       # orbit size (scene units)
@export var eccentricity := 0.05          # 0 = circle, near 1 = very stretched
@export var period := 200.0                # seconds for one full orbit
@export var time_scale := 1.0             # speed-up factor
@export_range(-180.0, 180.0) var inclination_deg := 36.0   # rotate about Y
@export_range(-180.0, 180.0) var omega_deg := 45.0         # rotate about Z
@export_range(-180.0, 180.0) var raan_deg := 45.0          # rotate about X
@export var draw_orbit_line := false
@export var orbit_line_color := Color(0.7, 0.8, 1.0, 0.35)

var _clock := 0.0


func _ready() -> void:
	if draw_orbit_line:
		_build_orbit_line()


func _process(delta: float) -> void:
	_clock += delta * time_scale
	position = _orbit_position(_clock)


# Solve Kepler's equation  E - e*sin(E) = M  with Newton's method.
func _solve_kepler(M: float) -> float:
	var e := eccentricity
	var E := M if e < 0.8 else PI
	for i in 50:
		var dE := (E - e * sin(E) - M) / (1.0 - e * cos(E))
		E -= dE
		if absf(dE) < 1e-12:
			break
	return E


# Same three rotations, in the same order, as the tutorial.
func _orient(p: Vector3) -> Vector3:
	p = p.rotated(Vector3.UP, deg_to_rad(inclination_deg))   # about Y
	p = p.rotated(Vector3.BACK, deg_to_rad(omega_deg))       # about Z
	p = p.rotated(Vector3.RIGHT, deg_to_rad(raan_deg))       # about X
	return p


# Position at a given time (planet at the origin = one focus of the ellipse).
func _orbit_position(time: float) -> Vector3:
	var M := fposmod(TAU / period * time, TAU)               # mean anomaly
	var E := _solve_kepler(M)                                # eccentric anomaly
	var a := semi_major_axis
	var e := eccentricity
	var flat := Vector3(
		a * (cos(E) - e),
		a * sqrt(1.0 - e * e) * sin(E),
		0.0
	)
	return _orient(flat)


# Draw the whole ellipse once, as a child of the parent so it follows it.
func _build_orbit_line() -> void:
	var mesh := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = orbit_line_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var steps := 128
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in steps + 1:
		var u := TAU * float(i) / float(steps)
		var flat := Vector3(
			semi_major_axis * (cos(u) - eccentricity),
			semi_major_axis * sqrt(1.0 - eccentricity * eccentricity) * sin(u),
			0.0
		)
		mesh.surface_add_vertex(_orient(flat))
	mesh.surface_end()

	var line := MeshInstance3D.new()
	line.mesh = mesh
	get_parent().add_child.call_deferred(line)
