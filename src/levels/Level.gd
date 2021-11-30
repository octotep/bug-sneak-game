extends Node2D
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.

# The "_" prefix is a convention to indicate that variables are private,
# that is to say, another node or script should not access them.
var _pause_menu_scene = preload("res://src/menus/ingame/PauseScreen.tscn")
var _game_over_scene = preload("res://src/menus/ingame/GameOverScreen.tscn")
var _win_scene = preload("res://src/menus/ingame/WinScreen.tscn")
var _congrats_scene = preload("res://src/menus/ingame/CongratulationScreen.tscn")
var _sign_overlay_scene = preload("res://src/menus/ingame/SignOverlay.tscn")

var _pause_menu
var _game_over_menu
var _win_menu
var _congrats_menu
var _sign_overlay

var _player

var _tilemaps = []

func _init():
	OS.min_window_size = OS.window_size

func _ready():
	# Create a new ui canvas
	var ui_canvas = CanvasLayer.new()
	ui_canvas.layer = 100
	self.add_child(ui_canvas)
	
	# Dynamically instantiate UI scenes into it
	_pause_menu = _pause_menu_scene.instance()
	ui_canvas.add_child(_pause_menu)
	_game_over_menu = _game_over_scene.instance()
	ui_canvas.add_child(_game_over_menu)
	_win_menu = _win_scene.instance()
	ui_canvas.add_child(_win_menu)
	_congrats_menu = _congrats_scene.instance()
	ui_canvas.add_child(_congrats_menu)
	_sign_overlay = _sign_overlay_scene.instance()
	ui_canvas.add_child(_sign_overlay)
	
	# Connect the alert across scenes so the player knows what's up
	_player = get_tree().get_nodes_in_group("player")[0]
	var _ret = _player.connect("game_over", self, "_game_over")
	_ret = _player.connect("win", self, "_win")
	_ret = _player.connect("open_sign", self, "_open_sign")
	_ret = _player.connect("toggle_gate", self, "_toggle_gate")
	
	findTileMapRecursive(self, _tilemaps)
	
	# Find bounding rectangle of level
	var camera_range = Rect2()
	
	for tilemap in _tilemaps:
		camera_range = camera_range.merge(tilemap.get_used_rect())
	
	var cell_size = _tilemaps[0].get_cell_size()
	var limit_left = camera_range.position.x * cell_size.x
	var limit_right = camera_range.end.x * cell_size.x
	var limit_top = camera_range.position.y * cell_size.y
	var limit_bottom = camera_range.end.y * cell_size.y
	
	for player in get_tree().get_nodes_in_group("player"):
		player.set_camera_extents(limit_left, limit_right, limit_top, limit_bottom)


func findTileMapRecursive(node, found_nodes):
	if node.is_class("TileMap"):
		found_nodes.append(node)
	for child in node.get_children():
		findTileMapRecursive(child, found_nodes)



func _unhandled_input(event):
	# The GlobalControls node, in the Stage scene, is set to process even
	# when the game is paused, so this code keeps running.
	# To see that, select GlobalControls, and scroll down to the Pause category
	# in the inspector.
	if event.is_action_pressed("toggle_pause"):
		var tree = get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().set_input_as_handled()


func _game_over():
	get_tree().paused = true
	_game_over_menu.open()
	
func _win():
	Global.beat_level(_player.current_alerts)
	get_tree().paused = true
	_player.visible = false
	
	if Global.did_win_game():
		_congrats_menu.open()
	else:
		_win_menu.open()
	
func _open_sign(input_text):
	get_tree().paused = true
	_sign_overlay.open(input_text)

func _toggle_gate(switch_id):
	for switch in get_tree().get_nodes_in_group("switch"):
		if (switch_id == switch.switch_id):
			switch.get_node("Sprite").frame = switch.get_node("Sprite").frame == 0
			
	for gate in get_tree().get_nodes_in_group("gate"):
		if (switch_id == gate.gate_id):
			if not gate.visible:
				gate.get_node("CollisionShape2D").disabled = false
				gate.visible = true
			else:
				gate.visible = false
				gate.get_node("CollisionShape2D").disabled = true
