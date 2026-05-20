extends Area2D

# Скорост на куршума
var speed: float = 600.0

# Посока, накъдето ще лети (ще я вземаме от роботчето)
var direction: Vector2 = Vector2.UP

# Пазим какъв цвят е куршумът (1 = син, 2 = червен, 3 = зелен)
var bullet_mode: int = 1

@onready var laser_sprite = $Sprite2D # Точното име на Sprite2D възела ти тук


func _ready() -> void:
	# Свързваме куршума със системата за сблъсък
	body_entered.connect(_on_body_entered)
	
	# Намираме играча в групата "Player", за да разберем в какъв мод е в момента
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		# Вземаме текущия мод на играча (1, 2 или 3) и го прехвърляме на куршума
		bullet_mode = player.current_mode
	
	# Вземаме картинката ръчно
	var sprite = get_node_or_null("Sprite2D")
	
	# Сменяме кадъра, за да се покаже само правилният лазер
	if sprite != null:
		# Понеже твоят bullet_mode е 1, 2, 3, а кадрите (frames) започват от 0:
		# 1 - 1 = 0 (Син) | 2 - 1 = 1 (Червен) | 3 - 1 = 2 (Зелен)
		sprite.frame = bullet_mode - 1
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
