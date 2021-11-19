extends Container

func _ready():
	$Cutscene.play("Opening Cutscene")


func _on_Cutscene_animation_finished(anim_name):
	var _ret = get_tree().change_scene("res://Level.tscn")
