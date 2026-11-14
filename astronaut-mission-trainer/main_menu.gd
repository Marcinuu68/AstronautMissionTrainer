extends Control

# Ścieżka do sceny właściwej gry (zmień na swoją nazwę pliku)
@export_file("*.tscn") var game_scene_path: String = "res://box.tscn"

# Ścieżka do sceny opcji (opcjonalnie)
@export_file("*.tscn") var options_scene_path: String = "res://settings.tscn"

func _on_start_button_pressed() -> void:
	# Przejście do sceny gry
	get_tree().change_scene_to_file(game_scene_path)

func _on_options_button_pressed() -> void:
	# Przejście do sceny opcji (jeśli istnieje)
	if ResourceLoader.exists(options_scene_path):
		get_tree().change_scene_to_file(options_scene_path)
	else:
		print("Scena opcji nie została jeszcze utworzona.")

func _on_quit_button_pressed() -> void:
	# Zamknięcie gry
	get_tree().quit()
