extends Area2D

# General exports for all vision cones
export var detect_radius = 150
export var field_of_view = 40
export var flash_frequency = 0.3
export var leniency = 0.65

export(GDScript) var movement_script

const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
const YELLOW = Color(1.0, 1.0, 0, 0.6)
const CYAN = Color(0, 0.7, 0.7, 0.4)
const CLEAR = Color(0, 0, 0, 0)

var draw_color

var in_view = false
var detecting = false
var detection_counter = 0
var flash_counter = 0

# We aren't using the node's collision mask because
# we DO want to collide with the player for detection purposes,
# but we DON'T want the player to occlude the cone.
const VISION_CONE_COLLISION_MASK = 8

var occlusion_exclusions = []

signal alerted

func _ready():
	
	if leniency == 0:
		draw_color = YELLOW
	else:
		draw_color = GREEN
	
	var _ret
	# Connect the alert across scenes so the player knows what's up
	for player in get_tree().get_nodes_in_group("player"):
		_ret = connect("alerted", player, "_on_alerted")
	
	# This allows for custom cone movement.
	# Default is static, though it inherits its parents' transforms.
	$VisionConeMovement.set_script(movement_script)
	
	# Because we can't know for certain what the tree looks like above the cone,
	# we instead just throw a `has_cone` variable into the actual owner.
	# This allows us to ignore any potential container Node2Ds or whatever else,
	# and exclude JUST the node that matters.
	var parent_node = self
	while not parent_node == null:
		if "has_cone" in parent_node:
			break
		parent_node = parent_node.get_parent()
	if not parent_node == null:
		occlusion_exclusions = [parent_node]

func _physics_process(_delta):
	
	# Set the collision polygon based on export vars
	var polygon = get_shape_points(
		position,
		detect_radius,
		rotation_degrees - field_of_view / 2,
		rotation_degrees + field_of_view / 2
	)
	
	if $VisibilityNotifier2D.is_on_screen():
		polygon = get_occluded_points(polygon)
	$VisionConePolygon.polygon = polygon

func _process(delta):
	
	rotation_degrees = $VisionConeMovement.update_angle()
	
	# Vision cones have various reasons to flash.
	# First we check if it's disabled, because that should always supersede everything else.
	# Then we check if the cone has detected the player.
	if not $DisableTimer.is_stopped():
		flash_counter += delta
		if flash_counter >= flash_frequency:
			flash_counter = 0
			if draw_color == CYAN:
				draw_color = CLEAR
			else:
				draw_color = CYAN
	elif not $AlertCooldownTimer.is_stopped():
		flash_counter += delta
		if flash_counter >= flash_frequency:
			flash_counter = 0
			if draw_color == RED:
				draw_color = CLEAR
			else:
				draw_color = RED
	else:
		if leniency == 0:
			draw_color = YELLOW
		else:
			draw_color = GREEN
	
	if detecting:
		
		detection_counter += delta
		if detection_counter >= leniency:
			handle_alert()
		
	elif detection_counter > 0:
		detection_counter -= delta
	
	if detection_counter < 0:
		detection_counter = 0
	
	update()

func start_detecting():
	if $AlertCooldownTimer.is_stopped() and $DisableTimer.is_stopped():
		detecting = true

func stop_detecting():
	detecting = false

func handle_alert():
	draw_color = RED
	$AlertCooldownTimer.start()
	emit_signal("alerted")
	detecting = false

func _on_VisionCone_body_entered(body):
	if body.is_in_group("player"):
		in_view = true
		start_detecting()

func _on_VisionCone_body_exited(body):
	if body.is_in_group("player"):
		in_view = false
		stop_detecting()

func _on_AlertCooldownTimer_timeout():
	flash_counter = 0
	if in_view:
		start_detecting()

func _on_DisableTimer_timeout():
	flash_counter = 0

func get_occluded_points(points_arc):
	var space_state = get_world_2d().direct_space_state
	var center = points_arc[0]
	
#	for i in range(points_arc.size()):
#
#		# Skip the first one because that's always the center
#		if i == 0:
#			continue
#
#		var point = points_arc[i]
#		var intersect_result = space_state.intersect_ray(
#			to_global(center),
#			to_global(point),
#			occlusion_exclusions,
#			VISION_CONE_COLLISION_MASK
#		)
#
#		# This means there was no intersection, and we can use the original point
#		if intersect_result.empty():
#			continue
#
#		points_arc.set(i, to_local(intersect_result.position))
	
	var occluder_poly = ConvexPolygonShape2D.new()
	occluder_poly.set_points(points_arc)
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(occluder_poly)
	query.transform = get_parent().get_global_transform()
	query.collision_layer = VISION_CONE_COLLISION_MASK
	var collided_shapes = space_state.intersect_shape(query)
	
	for shape in collided_shapes:
		var rid = Physics2DServer.body_get_shape(shape.rid, shape.shape)
		var phys_shape = Physics2DServer.shape_get_data(rid)
		var phys_type = Physics2DServer.shape_get_type(rid)
		var trans = Physics2DServer.body_get_shape_transform(shape.rid, shape.shape)
		print(phys_type)
		print(trans)
		print(trans.xform(phys_shape))
		
	
	return points_arc

func get_shape_points(center, radius, angle_from, angle_to):
	var nb_points = 48
	var points_arc = PoolVector2Array()
	points_arc.append(center)
	
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.append(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
	return points_arc

func draw_computed_polygon(color):
	var colors = PoolColorArray([color])
	draw_polygon($VisionConePolygon.polygon, colors)

func _draw():
	if leniency > 0 and $AlertCooldownTimer.is_stopped():
		var opacity = detection_counter / leniency
		draw_color = draw_color.blend(Color(1, 0, 0, opacity))
	draw_computed_polygon(draw_color)

func zapped():
	if $DisableTimer.is_stopped():
		draw_color = CYAN
	$DisableTimer.start()
