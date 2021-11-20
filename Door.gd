extends Area2D

signal approached_door
signal retreated_from_door

func _ready():
	for player in get_tree().get_nodes_in_group("player"):
		connect("approached_door", player, "_approached_door")
		connect("retreated_from_door", player, "_retreated_from_door")


func _on_Door_body_entered(body):
	emit_signal("approached_door")


func _on_Door_body_exited(body):
	emit_signal("retreated_from_door")
