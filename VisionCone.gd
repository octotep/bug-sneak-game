extends Node2D

export var detect_radius = 150
export var field_of_view = 40

var angle = 0
var direction = Vector2()
var pos = global_position


# Default
func update_angle():
	var new_direction = (pos - get_global_mouse_position()).normalized()
	angle = rad2deg(new_direction.angle()) - 90


func _process(_delta):
	
	pos = global_position
	update_angle()
	
	direction = Vector2(cos(deg2rad(angle + 90)), sin(deg2rad(angle + 90)))
	
	var detecting = false
	for node in get_tree().get_nodes_in_group('player'):
		if pos.distance_to(node.position) < detect_radius:
			var detect_direction = pos - node.global_position
			var angle_to_node = rad2deg(direction.angle_to(detect_direction))
			if (abs(angle_to_node) < field_of_view / 2):
				detecting = true
	
	if detecting:
		draw_color = RED
	else:
		draw_color = GREEN
		
	update()

const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)

var draw_color = GREEN

var font
func _ready():
	font = DynamicFont.new()
	font.font_data = load("res://assets/fonts/roboto/Roboto-Bold.ttf")
	font.size = 20


func _draw():
	
	draw_circle_arc_poly(
		position,
		detect_radius,
		angle - field_of_view / 2,
		angle + field_of_view / 2,
		draw_color
	)


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	draw_polygon(points_arc, colors)
