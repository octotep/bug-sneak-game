extends MarginContainer


func _on_Button3_pressed():
	get_tree().get_root().notification(NOTIFICATION_WM_QUIT_REQUEST)
	get_tree().quit()


func _on_Button_pressed():
	var _ret = get_tree().change_scene("res://Level.tscn")
