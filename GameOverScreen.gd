extends Control


export(Vector2) var _start_position = Vector2(0, -20)
export(Vector2) var _end_position = Vector2.ZERO
export(float) var fade_in_duration = 0.3
export(float) var fade_out_duration = 0.2

onready var center_cont = $ColorRect/CenterContainer
onready var main_menu_button = center_cont.get_node(@"VBoxContainer/MainMenu")
onready var level_select_button = center_cont.get_node(@"VBoxContainer/LevelSelect")
onready var quit_button = center_cont.get_node(@"VBoxContainer/Quit")

onready var root = get_tree().get_root()
onready var scene_root = root.get_child(root.get_child_count() - 1)
onready var tween = $Tween


func _ready():
	if (OS.get_name() == 'HTML5'):
		quit_button.visible = false
	hide()


func open():
	show()
	if (is_instance_valid(level_select_button)):
		level_select_button.grab_focus()
	else:
		main_menu_button.grab_focus()

	tween.interpolate_property(self, "modulate:a", 0.0, 1.0,
			fade_in_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(center_cont, "rect_position",
			_start_position, _end_position, fade_in_duration,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func _on_MainMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://TitleScreen.tscn")


func _on_Tween_all_completed():
	if modulate.a < 0.5:
		hide()

func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().get_root().notification(NOTIFICATION_WM_QUIT_REQUEST)
	get_tree().quit()

func _on_LevelSelect_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://LevelSelect.tscn")
