extends Control

# Промени "res://main.tscn" с точното име и път до твоята главна сцена на играта!
@export var game_scene_path: String = "res://main.tscn"

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

# Елементите от Credits прозореца
@onready var credits_panel: Panel = $CreditsPanel
@onready var back_button: Button = $CreditsPanel/MarginContainer/VBoxContainer/BackButton
@onready var revolut_button: Button = $CreditsPanel/MarginContainer/VBoxContainer/RevolutButton

func _ready() -> void:
	# Свързваме трите основни бутона
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Свързваме бутоните в Credits прозореца
	back_button.pressed.connect(_on_back_pressed)
	revolut_button.pressed.connect(_on_revolut_pressed) # Този ред активира Revolut бутона!

func _on_play_pressed() -> void:
	# Стартира играта
	get_tree().change_scene_to_file(game_scene_path)

func _on_credits_pressed() -> void:
	# 1. Показва прозореца с кредитите
	credits_panel.visible = true
	# 2. Скрива главното меню (бутоните Play, Credits, Quit)
	$VBoxContainer.visible = false

func _on_back_pressed() -> void:
	# 1. Скрива прозореца с кредитите
	credits_panel.visible = false
	# 2. Показва обратно главното меню
	$VBoxContainer.visible = true

func _on_quit_pressed() -> void:
	# Затваря играта
	get_tree().quit()

func _on_revolut_pressed() -> void:
	# Тази команда казва на операционната система (Android/Windows) да отвори линка в браузъра
	OS.shell_open("https://revolut.me/mariangerchev")
