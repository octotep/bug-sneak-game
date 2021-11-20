extends Node2D
# This class contains controls that should always be accessible, like pausing
# the game or toggling the window full-screen.

# The "_" prefix is a convention to indicate that variables are private,
# that is to say, another node or script should not access them.
onready var _pause_menu = $InterfaceLayer/PauseScreen
onready var _game_over_menu = $InterfaceLayer/GameOverScreen
onready var _win_menu = $InterfaceLayer/WinScreen

func _init():
	OS.min_window_size = OS.window_size

func _ready():
	# Connect the alert across scenes so the player knows what's up
	$Background/Player.connect("game_over", self, "_game_over")
	$Background/Player.connect("win", self, "_win")

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
	get_tree().paused = true
	$Background/Player.visible = false
	_win_menu.open()
