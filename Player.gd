extends KinematicBody2D


export var run_speed = Vector2(150.0, 350.0)
export var crawl_speed = Vector2(75.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_DETECT_DISTANCE = 20
const ALERT_OFFSET = 80

var _velocity = Vector2.ZERO
var in_door = false

signal game_over
signal win

enum STATE {
	IDLE,
	RUNNING,
	STOPPING,
	START_JUMP,
	MID_JUMP,
	FALLING,
	LANDING,
	CROUCHING,
	CRAWLING,
}
var _state = STATE.IDLE

func get_direction():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y = -1 # going uuuupppppppp
	return Vector2(x, y)

func _physics_process(delta):
	# Did we just win? Nice
	if Input.is_action_just_pressed("jump") and is_on_floor() and in_door:
		emit_signal("win")
		return
		
	var is_crouching = Input.is_action_pressed("down") and is_on_floor()

	var speed = run_speed
	if is_crouching:
		speed = crawl_speed
	
	var direction = get_direction()
	_velocity.x = direction.x * speed.x
	if direction.y != 0.0:
		_velocity.y = direction.y * speed.y
		
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			snap_vector = Vector2.ZERO
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, Vector2.UP, true, 4, 0.9, false)
	
	_velocity.y += gravity * delta
	
	# Update floor animations based on x value
	if _velocity.x > 0:
		$AnimatedSprite.set_flip_h(false)
	elif _velocity.x < 0:
		$AnimatedSprite.set_flip_h(true)
	
	if direction.x != 0 and is_on_floor() and not is_crouching:
		if($AnimationPlayer.current_animation != "run"):
			$AnimationPlayer.play("run")
		$AnimationPlayer.play("run")
		_state = STATE.RUNNING
	elif direction.x == 0 and _state == STATE.RUNNING and is_on_floor():
		$AnimationPlayer.play("stop")
		_state = STATE.STOPPING
	elif direction.x == 0 and _state == STATE.STOPPING and is_on_floor() and $AnimatedSprite.frame == 1:
		$AnimationPlayer.play("idle")
		_state = STATE.IDLE
	elif Input.is_action_just_pressed("jump") and _velocity.y < 0:
		$AnimationPlayer.play("jump")
		_state = STATE.START_JUMP
	elif _velocity.y >= -100 and not is_on_floor() and _state == STATE.START_JUMP:
		$AnimationPlayer.play("jump_mid")
		_state = STATE.MID_JUMP
	elif _velocity.y >= 0 and not is_on_floor():
		$AnimationPlayer.play("fall")
		_state = STATE.FALLING
	elif (_state == STATE.FALLING or _state == STATE.MID_JUMP or _state == STATE.START_JUMP) and is_on_floor():
		$AnimationPlayer.play("land")
		_state = STATE.LANDING
	elif _state == STATE.LANDING and $AnimatedSprite.frame == 1:
		if _velocity.x != 0:
			$AnimationPlayer.play("run")
			_state = STATE.RUNNING
		elif _velocity.x == 0:
			$AnimationPlayer.play("idle")
			_state = STATE.IDLE
	elif _velocity.x == 0 and is_on_floor() and is_crouching:
		$AnimationPlayer.play("crouch")
		_state = STATE.CROUCHING
	elif _velocity.x == 0 and is_on_floor() and Input.is_action_just_released("down"):
		$AnimationPlayer.play("idle")
		_state = STATE.IDLE
	elif _velocity.x != 0 and is_on_floor() and is_crouching:
		$AnimationPlayer.play("crawl")
		_state = STATE.CRAWLING


var max_alerts = 3
var current_alerts = 0

func _ready():
	for i in max_alerts:
		var new_alert = Sprite.new()
		new_alert.texture = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.texture
		new_alert.hframes = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.hframes
		$UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.add_child(new_alert)
		
	for alert in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.get_children():
			var x = (max_alerts - alert.get_index() - 1) * ALERT_OFFSET
			alert.position = Vector2(x, 40)


func _on_alerted():
	current_alerts += 1
	for alert in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.get_children():
			if alert.get_index() < current_alerts:
				alert.frame = 1
		
	if current_alerts >= max_alerts:
		emit_signal("game_over")


func _approached_door():
	in_door = true
	$AnimatedSprite/Sprite.visible = true

func _retreated_from_door():
	in_door = false
	$AnimatedSprite/Sprite.visible = false
