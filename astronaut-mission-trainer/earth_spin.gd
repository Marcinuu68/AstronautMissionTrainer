extends MeshInstance3D
# Spins the planet. Real Earth: 360 degrees per 86,400 s = 0.00417 deg/s.
# Raise time_scale to see it turn (e.g. 3600 = one rotation per 24 seconds).

@export var time_scale := 3600.0

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(360.0 / 86400.0) * time_scale * delta)
