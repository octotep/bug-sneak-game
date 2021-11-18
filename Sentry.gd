extends KinematicBody2D

onready var path_follow: PathFollow2D = get_parent()
export var drive_speed = 10

enum DIR {
	FORWARDS,
	BACKWARDS,
	IDLE,
}

var direction = DIR.FORWARDS

func _ready():
	# We do the looping logic ourselves so we can wait inbetween ends
	path_follow.set_loop(false)
	$AnimationPlayer.play("idle")

func _physics_process(delta):
	var velocity = Vector2()
	
	if direction == DIR.FORWARDS and path_follow.get_unit_offset() >= 1.0:
		direction = DIR.IDLE
		$PatrolWait.start()
	elif direction == DIR.BACKWARDS and path_follow.get_unit_offset() <= 0.0:
		direction = DIR.IDLE
		$PatrolWait.start()
	
	if direction == DIR.FORWARDS:
		velocity.x = drive_speed
	elif direction == DIR.BACKWARDS:
		velocity.x = -drive_speed
	else:
		velocity.x = 0
		
	path_follow.set_offset(path_follow.get_offset() + velocity.x * delta)

	if velocity.x == 0:
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("move")
	
	if direction == DIR.IDLE and $PatrolWait.is_stopped():
		if path_follow.get_unit_offset() >= 1.0:
			direction = DIR.BACKWARDS
			$Sprite.flip_h = true
			$Node2D.rotation_degrees = $Node2D.rotation_degrees - 180
		elif path_follow.get_unit_offset() <= 0.0:
			direction = DIR.FORWARDS
			$Sprite.flip_h = false
			$Node2D.rotation_degrees = $Node2D.rotation_degrees + 180
