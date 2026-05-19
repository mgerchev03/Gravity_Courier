extends Area2D

# Скорост на куршума
var speed: float = 600.0

# Посока, накъдето ще лети (ще я вземаме от роботчето)
var direction: Vector2 = Vector2.UP

# Пазим какъв цвят е куршумът (1 = син, 2 = червен, 3 = зелен)
var bullet_mode: int = 1

func _ready() -> void:
	# Свързваме куршума със системата за сблъсък
	body_entered.connect(_on_body_entered)
	
	# Вземаме картинката ръчно. Ако твоят възел се казва по друг начин, промени името в кавичките!
	var sprite = get_node_or_null("Sprite2D")
	
	# Ако намери картинката, тогава я оцветяваме
	if sprite != null:
		if bullet_mode == 1:
			sprite.modulate = Color(0.2, 0.6, 1.0) # Син лазер
		elif bullet_mode == 2:
			sprite.modulate = Color(1.0, 0.2, 0.2) # Червен лазер
		elif bullet_mode == 3:
			sprite.modulate = Color(0.2, 1.0, 0.2) # Зелен лазер
	else:
		print("Грешка: Не намерих възел Sprite2D в куршума!")

func _process(delta: float) -> void:
	# Куршумът лети постоянно в зададената посока
	position += direction * speed * delta

# Функция, която се задейства, когато куршумът удари нещо (стена или враг)
func _on_body_entered(body: Node) -> void:
	# Ако удари стените (Walls), куршумът се изтрива, за да не товари играта
	if body.name == "Walls" or body.get_parent().name == "Walls":
		queue_free()
	
	# ТУК ПО-КЪСНО: Ще добавим логиката за удряне на врагове (ако модът съвпада)
