extends Area2D

# Променливи на врага (горе в класа се дефинират само те)
var speed: float = 200.0
var enemy_mode: int = 1

func _ready() -> void:
	# Свързваме сигналите за сблъсък, когато врагът се роди
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Оцветяване на врага според неговия мод
	var sprite = get_node_or_null("Sprite2D") # Забележка: провери дали се казва Sprite2D или Sprite20 в сцената ти
	if sprite != null:
		if enemy_mode == 1: sprite.modulate = Color(0.2, 0.6, 1.0) # Син
		elif enemy_mode == 2: sprite.modulate = Color(1.0, 0.2, 0.2) # Червен
		elif enemy_mode == 3: sprite.modulate = Color(0.2, 1.0, 0.2) # Зелен

func _process(delta: float) -> void:
	# Врагът пада постоянно надолу
	position.y += speed * delta
	
	# Проверка за падане под екрана (ВЪТРЕ във функцията _process)
	if position.y > 1300:
		var main_node = get_tree().current_scene
		if main_node != null and main_node.has_method("take_damage"):
			main_node.take_damage(1.0) # Маха половин сърце
		queue_free()

# Функция за сблъсък с куршум (Area2D)
func _on_area_entered(area: Area2D) -> void:
	if "bullet_mode" in area:
		if area.bullet_mode == enemy_mode:
			print("УСПЕХ! Правилен мод. Врагът е унищожен!")
			area.queue_free()
			queue_free()
		else:
			print("ГРЕШЕН МОД! Куршумът изчезва.")
			area.queue_free()

# Функция за сблъсък с твоето роботче (RigidBody2D)
func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		print("ВРАГЪТ ТЕ УДАРУ ТЕБ!")
		
		# Взимаме кръв (ВЪТРЕ във функцията при сблъсък)
		var main_node = get_tree().current_scene
		if main_node != null and main_node.has_method("take_damage"):
			main_node.take_damage(2.0) # Маха цяло сърце
			
		queue_free()
