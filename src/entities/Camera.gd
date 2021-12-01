extends Area2D

export var min_angle = 0
export var max_angle = 180
export var scan_speed = 9.375

var scan_direction = 1

var has_cone = true

func _process(_delta):
	
	var new_angle = rotation_degrees + ((scan_speed * _delta) * scan_direction)
	
	if new_angle >= max_angle or new_angle <= min_angle:
		scan_direction *= -1
	
	rotation_degrees = clamp(new_angle, min_angle, max_angle)

func zapped():
	$VisionCone.zapped()
