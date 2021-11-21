extends Container

func _ready():
	$Cutscene.play("Opening Cutscene")


func _on_Cutscene_animation_finished(anim_name):
	Global.game_state["levels_unlocked"] = 1
	print(Global.game_state)
	var _ret = get_tree().change_scene("res://LevelSelect.tscn")
