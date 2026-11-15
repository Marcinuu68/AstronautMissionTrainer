extends Node3D
# Keeps the same face of the Moon turned toward Earth (tidal locking).
# Attach to "Pivot": Earth > Satelite (orbit.gd) > Pivot (this script) > Mesh.
# Pivot's parent is Satelite, and Satelite's parent is Earth.
# If the wrong side faces Earth, rotate the Mesh node on Y (90, 180 or -90).

func _process(_delta: float) -> void:
	var earth := get_parent().get_parent() as Node3D
	if earth == null:
		return
	var target := earth.global_position
	if global_position.distance_to(target) < 0.001:
		return
	look_at(target)
