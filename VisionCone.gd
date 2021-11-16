extends Area2D

# General exports for all vision cones
export var detect_radius = 150
export var field_of_view = 40
export var flash_frequency = 0.3

export(GDScript) var movement_script

const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
const YELLOW = Color(1.0, 1.0, 0, 0.6)

var draw_color = GREEN

var detecting = false
var flash_counter = 0

signal alerted


func _ready():
	
	# Connect the alert across scenes so the player knows what's up
	for player in get_tree().get_nodes_in_group("player"):
		connect("alerted", player, "_on_alerted")
	
	# Set the collision polygon based on export vars
	var polygon = get_shape_points(
		position,
		detect_radius,
		rotation_degrees - field_of_view / 2,
		rotation_degrees + field_of_view / 2
	)
	$VisionConePolygon.polygon = polygon


func _process(delta):
	
	# This allows for custom cone movement.
	# Default is static, though it inherits its parents' transforms.
	$VisionConeMovement.set_script(movement_script)
	rotation_degrees = $VisionConeMovement.update_angle()
	
	# We need some indication that the cone has spotted the player,
	# and that there's some cooldown where it won't spot the player again.
	if not $AlertCooldownTimer.is_stopped():
		flash_counter += delta
		if flash_counter >= flash_frequency:
			flash_counter = 0
			if draw_color == RED:
				draw_color = YELLOW
			else:
				draw_color = RED
	else:
		draw_color = GREEN
	
	update()


func handle_alert():
	draw_color = RED
	$AlertCooldownTimer.start()
	emit_signal("alerted")


func _on_VisionCone_body_entered(body):
	if body.is_in_group("player"):
		detecting = true
		if $AlertCooldownTimer.is_stopped():
			handle_alert()


func _on_AlertCooldownTimer_timeout():
	flash_counter = 0
	if detecting:
		handle_alert()


func _on_VisionCone_body_exited(body):
	if body.is_in_group("player"):
		detecting = false


func get_shape_points(center, radius, angle_from, angle_to):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	return points_arc


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var colors = PoolColorArray([color])
	var points_arc = get_shape_points(center, radius, angle_from, angle_to)
	draw_polygon(points_arc, colors)


func _draw():
	draw_circle_arc_poly(
		position,
		detect_radius,
		rotation_degrees - field_of_view / 2,
		rotation_degrees + field_of_view / 2,
		draw_color
	)
