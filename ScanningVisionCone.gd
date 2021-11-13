extends Node2D

var scan_direction = 1

func update_angle():
	var min_angle = get_parent().min_angle
	var max_angle = get_parent().max_angle
	var scan_speed = get_parent().scan_speed
	var angle = get_parent().angle
	
	var new_angle = angle + scan_speed * scan_direction
	
	if new_angle >= max_angle or new_angle <= min_angle:
		scan_direction *= -1
	
	return new_angle
