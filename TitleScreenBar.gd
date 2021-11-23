extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 600


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.x > 3000:
		queue_free()
	move_and_slide(velocity)
