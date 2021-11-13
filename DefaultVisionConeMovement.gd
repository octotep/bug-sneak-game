extends Node2D

# Default - follow the mouse. Prooooobably no real use in the game,
# so should always be overridden.
func update_angle():
	var new_direction = (global_position - get_global_mouse_position()).normalized()
	return rad2deg(new_direction.angle()) - 90
