extends Node2D

var angle = 0
var direction = Vector2()

func _process(delta):
	var pos = global_position
	direction = (pos - get_global_mouse_position()).normalized()
	angle = rad2deg(direction.angle())

	$AnimatedSprite.rotation_degrees = angle
