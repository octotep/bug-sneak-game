extends Container

onready var _pause_menu = $UI/PauseScreen

func _ready():
	$Cutscene.play("Opening Cutscene")

func start_game():
	Global.game_state = Global.base_game_state
	Global.game_state["levels_unlocked"] = 1
	Global.save_game()
	Global.save_game()
	get_tree().change_scene("res://src/menus/LevelSelect.tscn")

func _on_Cutscene_animation_finished(_anim_name):
	start_game()

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


func _on_PauseScreen_skip_intro():
	start_game()
