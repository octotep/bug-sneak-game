extends MarginContainer

var levels = [
	{
		"text": "Learning the Basics",
		"path": "res://Level.tscn"
	},
]

onready var item_list = $VBoxContainer/MarginContainer/HBoxContainer/ItemList

func _ready():
	var levels_unlocked = Global.game_state["levels_unlocked"]
	var min_level = int(min(levels_unlocked, len(levels)))
	for i in range(min_level):
		var level = levels[i]
		var play_level = load("res://assets/play_level.png")
		var beat_level = load("res://assets/beat_level.png")
		if i < levels_unlocked - 1:
			item_list.add_item(level["text"], beat_level, true)
		else:
			item_list.add_item(level["text"], play_level, true)			
	
	Global.save_game()
	

func _on_ItemList_item_selected(index):
	Global.current_level = index
	var level_scene = levels[index]["path"]
	get_tree().change_scene(level_scene)
