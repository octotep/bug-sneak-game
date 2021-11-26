extends Control


onready var color_rect = $ColorRect
onready var text_area = $ColorRect/Label
onready var close_button = $ColorRect/Close

onready var root = get_tree().get_root()

func _ready():
	hide()

func open(input_text):
	show()
	text_area.anchor_bottom = 1
	text_area.anchor_right = 1
	text_area.margin_bottom = -50
	text_area.margin_top = 25
	text_area.margin_right = -25
	text_area.margin_left = 25
	text_area.text = input_text.c_unescape()
	text_area.show()
	close_button.grab_focus()
	

func close():
	get_tree().paused = false
	close_button.release_focus()
	text_area.hide()
	hide()


func _process(delta):
	if Input.is_action_just_pressed("toggle_pause"):
		close()


func _on_Close_pressed():
	close()
