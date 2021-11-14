extends Area2D

# General exports for all vision cones
export var detect_radius = 150
export var field_of_view = 40

# Scanning specific exports
export var min_angle = 0
export var max_angle = 180
export var scan_speed = 0.15

export(GDScript) var movement_script

var angle = 0
var detecting = false


func _process(_delta):
	
	$VisionConeMovement.set_script(movement_script)
	angle = $VisionConeMovement.update_angle()
	
#	var polygon = get_shape_points(
#		position,
#		detect_radius,
#		angle + 45 - field_of_view / 2,
#		angle + 45 + field_of_view / 2
#	)
#	$CollisionPolygon2D.polygon = polygon
	
	update()


const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)

var draw_color = GREEN


func _on_VisionCone_body_entered(body):
	if body.is_in_group("player"):
		detecting = true
		draw_color = RED


func _on_VisionCone_body_exited(body):
	if body.is_in_group("player"):
		detecting = false
		draw_color = GREEN


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
		angle - field_of_view / 2,
		angle + field_of_view / 2,
		draw_color
	)
	
	var colors = PoolColorArray([Color(0, 0, 1.0, 0.5)])
	draw_polygon($VisionConePolygon.polygon, colors)
