extends Control

@onready var settings_panel: Control = $Settings
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/Settings
@onready var exit_button: Button = $VBoxContainer/Exit
@onready var back_button: Button = $Settings/Back

func _ready() -> void:
	start_button.pressed.connect(_start_game)
	settings_button.pressed.connect(_show_settings.bind(true))
	back_button.pressed.connect(_show_settings.bind(false))
	exit_button.pressed.connect(_exit_game)
	_show_settings(false)

func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _exit_game() -> void:
	get_tree().quit()

func _show_settings(is_open: bool) -> void:
	settings_panel.visible = is_open
	start_button.visible = not is_open
	settings_button.visible = not is_open
	exit_button.visible = not is_open
