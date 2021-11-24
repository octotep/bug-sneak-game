extends Area2D

export var sign_text = ""

signal approached_sign(current_sign)
signal retreated_from_sign

func _ready():
	for player in get_tree().get_nodes_in_group("player"):
		connect("approached_sign", player, "_approached_sign")
		connect("retreated_from_sign", player, "_retreated_from_sign")


func _on_Sign_body_entered(body):
	emit_signal("approached_sign", self)


func _on_Sign_body_exited(body):
	emit_signal("retreated_from_sign")
