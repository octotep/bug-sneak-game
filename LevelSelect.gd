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
		item_list.add_item(level["text"], null, true)
	
	Global.save_game()
	

func _on_ItemList_item_selected(index):
	Global.current_level = index
	var level_scene = levels[index]["path"]
	get_tree().change_scene(level_scene)
