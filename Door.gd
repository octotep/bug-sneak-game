extends Area2D

signal approached_door
signal retreated_from_door

func _ready():
	var _ret
	for player in get_tree().get_nodes_in_group("player"):
		_ret = connect("approached_door", player, "_approached_door")
		_ret = connect("retreated_from_door", player, "_retreated_from_door")


func _on_Door_body_entered(_body):
	emit_signal("approached_door")


func _on_Door_body_exited(_body):
	emit_signal("retreated_from_door")
