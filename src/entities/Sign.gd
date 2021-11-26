extends Area2D

export var sign_text = ""

signal approached_sign(current_sign)
signal retreated_from_sign

func _ready():
	var _ret
	for player in get_tree().get_nodes_in_group("player"):
		_ret = connect("approached_sign", player, "_approached_sign")
		_ret = connect("retreated_from_sign", player, "_retreated_from_sign")


func _on_Sign_body_entered(_body):
	emit_signal("approached_sign", self)


func _on_Sign_body_exited(_body):
	emit_signal("retreated_from_sign")
