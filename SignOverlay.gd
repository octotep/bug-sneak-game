extends Control


onready var color_rect = $ColorRect
onready var text_area = $ColorRect/Label
onready var close_button = $ColorRect/Close

onready var root = get_tree().get_root()
onready var scene_root = root.get_child(root.get_child_count() - 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	hide() # Replace with function body.

func open(input_text):
	show()
	text_area.anchor_bottom = 1
	text_area.anchor_right = 1
	text_area.margin_bottom = -75
	text_area.margin_top = 50
	text_area.margin_right = -50
	text_area.margin_left = 50
	text_area.text = input_text.c_unescape()
	text_area.show()
	close_button.grab_focus()
	
func close():
	get_tree().paused = false
	close_button.release_focus()
	text_area.hide()
	hide()


func _on_Close_pressed():
	close()
