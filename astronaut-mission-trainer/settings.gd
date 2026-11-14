extends Control

# Ścieżka do menu głównego (dopasuj do nazwy swojego pliku)
@export_file("*.tscn") var main_menu_path: String = "res://main_menu.tscn"

# Referencje do węzłów (dostosuj ścieżki, jeśli Twoja struktura węzłów jest inna)
@onready var volume_slider: HSlider = $VBoxContainer/HBoxContainer/Volume
@onready var fullscreen_toggle: CheckButton = $"VBoxContainer/Fullscreen switch"

func _ready() -> void:
	# Ustawienie początkowego stanu przycisku pełnego ekranu na podstawie aktualnego trybu okna
	fullscreen_toggle.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

# Obsługa suwaka głośności
func _on_h_slider_value_changed(value: float) -> void:
	# Przeliczenie wartości na decybele (lub zapisanie do globalnego menedżera dźwięku)
	print("Nowa głośność: ", value)

# Obsługa przełącznika pełnego ekranu
func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Powrót do menu głównego po kliknięciu przycisku
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)
