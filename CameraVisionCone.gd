extends "res://VisionCone.gd"

export var starting_angle = 0
export var max_angle = 180
export var turn_speed = 0.15

var turn_direction = 1


# Sweep back and forth
func update_angle():
	angle += turn_speed * turn_direction
	if angle >= max_angle or angle <= starting_angle:
		turn_direction *= -1


func _ready():
	angle = starting_angle


# Call base process
func _process(delta):
	._process(delta)
