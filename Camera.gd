extends Node2D

var angle = 0
var direction = Vector2()

func _process(delta):
	$AnimatedSprite.rotation_degrees = $CameraVisionCone.angle + 90
