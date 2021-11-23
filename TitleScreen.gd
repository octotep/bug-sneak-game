extends MarginContainer

onready var _continue_button = $MenuLayer/MarginContainer/VBoxContainer/Buttons/Continue
onready var _quit_button = $MenuLayer/MarginContainer/VBoxContainer/Buttons/Quit

var Bar = preload ("res://TitleScreenBar.tscn")


func _init():
	OS.min_window_size = OS.window_size
	
func _ready():
	Global.load_game()
	
	if (OS.get_name() == 'HTML5'):
		_quit_button.visible = false
	if not Global.does_save_file_exist():
		_continue_button.visible = false

func _on_BarTimer_timeout():
	print(get_viewport().size)
	var e = Bar.instance()
	var pos = Vector2(-(get_viewport().size.x / 2), randi() % int(get_viewport().size.y))

	if randf() < 0.5:
		# On the left
		pos.x -= rand_range(50.0, 200.0)
		pos.y -= rand_range(-50.0, 60.0)
	else:
		# On the right
		pos.x += rand_range(50.0, 200.0)
		pos.y += rand_range(-50.0, 60.0)

	e.position = pos
	add_child(e)
	
func _on_NewGame_pressed():
	var _ret = get_tree().change_scene("res://Intro.tscn")

func _on_Quit_pressed():
	get_tree().get_root().notification(NOTIFICATION_WM_QUIT_REQUEST)
	get_tree().quit()


func _on_Continue_pressed():
	var _ret = get_tree().change_scene("res://LevelSelect.tscn")
