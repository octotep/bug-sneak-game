extends Node2D

func _draw():
	var detect_radius = 100
	var angle = 45
	var field_of_view = 80
	var draw_color = Color(1.0, 0, 0)
	
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
