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
	for i in range(levels_unlocked):
		var level = levels[i]
		item_list.add_item(level["text"], null, true)
	
	print(Global.game_state)
	Global.save_game()
	

func _on_ItemList_item_selected(index):
	var level_scene = levels[index]["path"]
	get_tree().change_scene(level_scene)
