extends KinematicBody2D

export var gate_id = 0
export var start_opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_opened:
		visible = false
		$CollisionShape2D.disabled = true
