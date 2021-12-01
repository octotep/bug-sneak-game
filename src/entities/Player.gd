extends KinematicBody2D


export var run_speed = Vector2(150.0, 350.0)
export var crawl_speed = Vector2(75.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_DETECT_DISTANCE = 20
const ALERT_OFFSET = 80

var _velocity = Vector2.ZERO
var in_door = false
var in_sign = false
var in_switch = false
var in_charge = false
var current_sign = null
var current_switch = null
var current_charge = null

signal game_over
signal win
signal open_sign(input_text)
signal toggle_gate(switch_id)

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

var zap_timer = 0 # timers below 0.5 seconds aren't recommended, so we handle it in code
var zap_time_max = 0.25
var zapping = false
var num_zaps = 0
var max_zaps = 1
var max_alerts = 3
var current_alerts = 0

func get_direction():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y = -1 # going uuuupppppppp
	return Vector2(x, y)

func _physics_process(delta):
	# Did we just win? Nice
	if Input.is_action_just_pressed("down") and is_on_floor() and in_door:
		emit_signal("win")
		return
		
	if Input.is_action_just_pressed("down") and is_on_floor() and in_sign:
		emit_signal("open_sign", current_sign.sign_text)
		return
		
	if Input.is_action_just_pressed("down") and is_on_floor() and in_switch:
		emit_signal("toggle_gate", current_switch.switch_id)
		return
		
	var is_crouching = Input.is_action_pressed("down") and is_on_floor() and not in_door and not in_sign and not in_switch

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
	# KinematicBody2D's have borked physics when trying to flip their scales.
	# Setting global transforms like this is a workaround.
	# I'll leave the local scale transform commented, to show how simple it *could* have been.
	if _velocity.x > 0:
		set_global_transform(Transform2D(Vector2(1, 0), Vector2(0, 1), position))
#		scale.x = 1
	elif _velocity.x < 0:
		set_global_transform(Transform2D(Vector2(-1, 0), Vector2(0, 1), position))
#		scale.x = -1
	
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
	
	update()

func _process(delta):
	
	# Zapping
	if $Upgrades.has_zapper:

		if zap_timer > zap_time_max:
			zapping = false
			zap_timer = 0
			$Zapper/ZapperSprite.visible = false
			$Zapper/CollisionShape2D.disabled = true

		if num_zaps > 0 and zap_timer == 0 and Input.is_action_just_pressed("zap"):
			zapping = true
			for zap in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.get_children():
				if zap.get_index() == max_zaps - num_zaps:
					zap.frame = 1
			num_zaps -= 1
		
		if zapping:
			zap_timer += delta
			$Zapper/ZapperSprite.visible = true
			$Zapper/CollisionShape2D.disabled = false
		
		if num_zaps < max_zaps and in_charge:
			num_zaps += 1
			current_charge.collected()
			for zap in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.get_children():
				if zap.get_index() == max_zaps - num_zaps:
					zap.frame = 0

func _ready():
	for i in max_alerts:
		var new_alert = Sprite.new()
		new_alert.texture = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.texture
		new_alert.hframes = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.hframes
		$UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.add_child(new_alert)
		
	for alert in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.get_children():
			var x = (max_alerts - alert.get_index() - 1) * ALERT_OFFSET
			alert.position = Vector2(x, 40)
	
	# Fresh zaps
	if $Upgrades.has_zapper == true:
		num_zaps = max_zaps
		if num_zaps > 0:
			$UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/Label2.visible = true
			$UI/MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Zap.visible = true
		
	for i in num_zaps:
		var new_zap = Sprite.new()
		new_zap.texture = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.texture
		new_zap.hframes = $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.hframes
		$UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.add_child(new_zap)
		
	for zap in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/zaps.get_children():
			var x = (num_zaps - zap.get_index() - 1) * ALERT_OFFSET
			zap.position = Vector2(x + 418, 40)

func _on_alerted():
	current_alerts += 1
	for alert in $UI/MarginContainer/VBoxContainer/HBoxContainer/Control2/alerts.get_children():
			if alert.get_index() < current_alerts:
				alert.frame = 1
		
	if current_alerts >= max_alerts:
		emit_signal("game_over")
	else:
		var player = get_node("/root/MusicPlayer")
		player.play_alert_bgm()


func set_camera_extents(left, right, top, bottom):
	$Camera2D.limit_left = left
	$Camera2D.limit_right = right
	$Camera2D.limit_top = top
	$Camera2D.limit_bottom = bottom


func _approached_door():
	in_door = true
	$AnimatedSprite/EnterDoorSprite.visible = true

func _retreated_from_door():
	in_door = false
	$AnimatedSprite/EnterDoorSprite.visible = false
	
func _approached_sign(curr_sign):
	in_sign = true
	current_sign = curr_sign
	$AnimatedSprite/EnterDoorSprite.visible = true

func _retreated_from_sign():
	in_sign = false
	current_sign = null
	$AnimatedSprite/EnterDoorSprite.visible = false
	
func _approached_switch(curr_switch):
	in_switch = true
	current_switch = curr_switch
	$AnimatedSprite/EnterDoorSprite.visible = true

func _retreated_from_switch():
	in_switch = false
	current_switch = null
	$AnimatedSprite/EnterDoorSprite.visible = false

func _approached_charge(curr_charge):
	in_charge = true
	current_charge = curr_charge

func _retreated_from_charge():
	in_charge = false
	current_charge = null
