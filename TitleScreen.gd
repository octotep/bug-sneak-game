extends MarginContainer

func _init():
	OS.min_window_size = OS.window_size
	if (OS.get_name() == 'HTML5'):
		self.visible = false

func _on_NewGame_pressed():
	var _ret = get_tree().change_scene("res://Level.tscn")

func _on_Quit_pressed():
	get_tree().get_root().notification(NOTIFICATION_WM_QUIT_REQUEST)
	get_tree().quit()
