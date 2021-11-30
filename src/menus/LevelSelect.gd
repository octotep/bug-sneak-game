extends MarginContainer

onready var item_list = $VBoxContainer/MarginContainer/HBoxContainer/ItemList
onready var levels_unlocked = Global.game_state["levels_unlocked"]
onready var min_level = int(min(levels_unlocked, len(Global.levels)))
onready var v_scroll = item_list.get_v_scroll()
var alert_containers = []

func _ready():
	
	# Set this to an arbitrarily high number, since the default is always just 100 for some reason
	v_scroll.set_max(1000000)
	v_scroll.set_value(v_scroll.get_max())
	
	for i in range(min_level):
		var level = Global.levels[i]
		var play_level = load("res://assets/play_level.png")
		var beat_level = load("res://assets/beat_level.png")
		if i < levels_unlocked - 1:
			item_list.add_item(level["text"], beat_level, true)
			
			var icon = item_list.get_item_icon(i)
			var icon_rect = item_list.get_item_icon_region(i)
			
			var alert_container = Node2D.new()
			alert_container.position.x = icon_rect.position.x
			var y_offset = icon.get_height() + get_constant("icon_margin", "ItemList")
			y_offset *= i
			alert_container.position.y = y_offset + 6 - v_scroll.get_value()
			
			var alert_label = item_list.get_node("AlertLabel").duplicate()
			alert_label.text = "ALERTS\n" + str(Global.game_state["alert_counts"][i])
			
			alert_container.add_child(alert_label)
			item_list.add_child(alert_container)
			alert_containers.append(alert_container)
		else:
			item_list.add_item(level["text"], play_level, true)
	
	Global.save_game()
	
	var player = get_node("/root/MusicPlayer")
	player.play_titlescreen_bgm()

func _process(delta):
	for i in range(alert_containers.size()):
		var container = alert_containers[i]
		var icon = item_list.get_item_icon(i)
		var y_offset = icon.get_height() + get_constant("icon_margin", "ItemList")
		y_offset *= i
		container.position.y = y_offset + 6 - v_scroll.get_value()

func _exit_tree():
	var player = get_node("/root/MusicPlayer")
	player.play_level_bgm()

func _on_ItemList_item_selected(index):
	Global.current_level = index
	var level_scene = Global.levels[index]["path"]
	var _ret = get_tree().change_scene(level_scene)
