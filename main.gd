extends Node2D

# Зареждаме сцените на куршума и на врага в паметта на играта
const BULLET_SCENE = preload("res://bullet.tscn")
const ENEMY_SCENE = preload("res://enemy.tscn")

# Връзки към петте сърца в CanvasLayer
@onready var hearts = [
	$CanvasLayer/HBoxContainer/Heart1, 
	$CanvasLayer/HBoxContainer/Heart2, 
	$CanvasLayer/HBoxContainer/Heart3, 
	$CanvasLayer/HBoxContainer/Heart4, 
	$CanvasLayer/HBoxContainer/Heart5
]

# Зареждане на трите състояния на сърцата в паметта
var img_full = preload("res://Full_Hearth.png")  # Обърни внимание дали буквите са големи/малки, точно както са във FileSystem!
var img_half = preload("res://heart_half.png")
var img_empty = preload("res://Empty_Hearth.png")

# --- ПРОМЕНЛИВА ЗА ЖИВОТА ---
# 5 пълни сърца по 2 точки всяко = 10.0 общо точки живот
var health: float = 10.0 

# Определя колко силно да дърпа гравитацията
var gravity_strength: float = 980.0

# Променливи за засичане на свайпването и кликовете
var touch_start_pos: Vector2 = Vector2.ZERO
var min_swipe_distance: float = 50.0

# Пазим времето за бързо чукване (Tap)
var touch_start_time: float = 0.0
var max_tap_time: float = 0.25 

# Променлива за текущия мод (1 = Син, 2 = Червен, 3 = Зелен)
var current_mode: int = 1

# Пазим таймера за враговете в променлива
var enemy_spawn_timer: Timer

# Път към компонентите на роботчето
@onready var player_sprite = $RigidBody2D/Sprite2D
@onready var player_body = $RigidBody2D

func _ready() -> void:
	# Начална гравитация стандартно надолу
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN)
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity_strength)
	
	# Оцветяваме роботчето в синьо в началото
	change_player_color()
	
	# --- СЪЗДАВАНЕ НА ТАЙМЕР ЗА ВРАГОВЕ ---
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = 2.0 # На всеки 2 секунди се ражда нов враг
	enemy_spawn_timer.autostart = true
	enemy_spawn_timer.timeout.connect(_spawn_enemy) # Свързваме го с функцията за раждане
	add_child(enemy_spawn_timer)

func _input(event: InputEvent) -> void:
	# Универсално засичане на докосвания за телефон
	if event is InputEventMouseButton:
		if event.pressed:
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			var touch_end_pos = event.position
			var touch_duration = (Time.get_ticks_msec() / 1000.0) - touch_start_time
			var swipe_vector = touch_end_pos - touch_start_pos
			
			# Проверка за ТАР (Чукване)
			if swipe_vector.length() < min_swipe_distance and touch_duration < max_tap_time:
				_handle_mobile_tap(touch_end_pos)
			else:
				# Проверка за СВАЙП (Гравитация)
				_check_swipe(touch_start_pos, touch_end_pos)

func _handle_mobile_tap(tap_position: Vector2) -> void:
	# Горна половина на екрана -> СТРЕЛЯ!
	if tap_position.y < 640:
		shoot_bullet()
	else:
		# Долна половина на екрана -> СМЕНЯ ЦВЕТА!
		_cycle_modes()

func _cycle_modes() -> void:
	current_mode += 1
	if current_mode > 3:
		current_mode = 1
		
	change_player_color()

func _check_swipe(start: Vector2, end: Vector2) -> void:
	var swipe_vector = end - start
	if swipe_vector.length() < min_swipe_distance:
		return
		
	if abs(swipe_vector.x) > abs(swipe_vector.y):
		if swipe_vector.x > 0: _change_gravity(Vector2.RIGHT)
		else: _change_gravity(Vector2.LEFT)
	else:
		if swipe_vector.y > 0: _change_gravity(Vector2.DOWN)
		else: _change_gravity(Vector2.UP)

func _change_gravity(new_direction: Vector2) -> void:
	PhysicsServer2D.area_set_param(get_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, new_direction)
	print("Промяна на гравитацията към: ", new_direction)

func change_player_color() -> void:
	if current_mode == 1: player_sprite.modulate = Color(0.2, 0.6, 1.0)
	elif current_mode == 2: player_sprite.modulate = Color(1.0, 0.2, 0.2)
	elif current_mode == 3: player_sprite.modulate = Color(0.2, 1.0, 0.2)

func shoot_bullet() -> void:
	var new_bullet = BULLET_SCENE.instantiate()
	new_bullet.bullet_mode = current_mode
	new_bullet.global_position = player_body.global_position
	new_bullet.direction = Vector2.UP
	new_bullet.rotation = 0
	add_child(new_bullet)

# Тази функция взима enemy.tscn и го пуска в играта автоматично!
func _spawn_enemy() -> void:
	var new_enemy = ENEMY_SCENE.instantiate()
	
	# Даваме му произволен цвят/режим (1, 2 или 3)
	new_enemy.enemy_mode = randi_range(1, 3)
	
	# Ражда се на случайна позиция по широчината на екрана (между 50 и 670 пиксела)
	var random_x = randf_range(50.0, 670.0)
	
	# Позиция Y е -50, за да пада от тавана извън видимия екран в началото
	new_enemy.position = Vector2(random_x, -50.0)
	
	add_child(new_enemy)
	print("Пада нов враг с цвят: ", new_enemy.enemy_mode)

# --- НОВИ ФУНКЦИИ ЗА ПРЕМАХВАНЕ НА КРЪВ И ОБНОВЯВАНЕ НА СЪРЦАТА ---

func take_damage(amount: float) -> void:
	health -= amount
	print("Оставащ живот: ", health)
	update_hearts_ui()
	
	if health <= 0:
		print("ИГРАТА СВЪРШИ!")
		get_tree().reload_current_scene()

func update_hearts_ui() -> void:
	for i in range(5):
		# Смятаме стойността за всяко конкретно сърце
		var heart_value = health - (i * 2)
		if heart_value >= 2:
			hearts[i].texture = img_full
		elif heart_value == 1:
			hearts[i].texture = img_half
		else:
			hearts[i].texture = img_empty
