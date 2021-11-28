extends Area2D

export var switch_id = 0

signal approached_switch(current_switch)
signal retreated_from_switch

func _ready():
	var _ret
	for player in get_tree().get_nodes_in_group("player"):
		_ret = connect("approached_switch", player, "_approached_switch")
		_ret = connect("retreated_from_switch", player, "_retreated_from_switch")


func _on_Switch_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("approached_switch", self)


func _on_Switch_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("retreated_from_switch")
