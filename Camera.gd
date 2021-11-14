extends Node2D


func _process(delta):
	$AnimatedSprite.rotation_degrees = $VisionCone.angle + 90
