extends CharacterBody3D

@export var current_speed: float
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 8.0
@export var mouse_sensitivity: float = 0.002

@onready var ray_cast: RayCast3D = $Head/RayCast3D
@onready var head: Node3D = $Head

# Wczytanie sceny menu od kolegi (dopasuj ścieżkę, jeśli plik jest w innym folderze)
#var side_menu_scene = preload("res://side_menu.tscn")
var menu_instance = null
var is_paused: bool = false
var is_sprinting: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Używamy _input, aby klawisz ESC działał również wtedy, gdy gra jest zapauzowana
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ui_cancel to domyślnie ESC
		if is_paused:
			resume_game()
		else:
			pause_game()

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true # Zatrzymuje fizykę i procesy w grze
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Odblokowuje kursor myszy
	
	# Tworzy instancję menu kolegi i dodaje ją do ekranu
	#var menu_instance = side_menu_scene.instantiate()
	#get_tree().root.add_child(menu_instance)

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false # Wznawia grę
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Blokuje kursor z powrotem do sterowania FPS
	
	# Usuwa menu z ekranu
	if menu_instance:
		menu_instance.queue_free()
		menu_instance = null

func _unhandled_input(event: InputEvent) -> void:
	# Jeśli gra jest zapauzowana, ignorujemy interakcję i ruch myszą
	if is_paused:
		return

	if event.is_action_pressed("interact"):
		if ray_cast.is_colliding():
			var hit_object = ray_cast.get_collider()
			if hit_object && hit_object.has_method("interact"):
				hit_object.interact()
	
	# Obsługa rozglądania się myszką
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	# Jeśli gra jest zapauzowana, nie wykonujemy kodu ruchu ani grawitacji
	if is_paused:
		return

	# Płynne sprawdzanie sprintu w każdym klatkuj fizyki (czy klawisz jest wciśnięty)
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	else:
		current_speed = walk_speed

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
