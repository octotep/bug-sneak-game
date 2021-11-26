extends Node

onready var fore_player = $Foreground
onready var back_player = $Background

var _title_bgm = preload("res://assets/sounds/music/GHGO2021 TITLE redux.ogg")
var _level_bgm = preload("res://assets/sounds/music/GHGO2021 BGM redux.ogg")
var _alert_bgm = preload("res://assets/sounds/music/GHGO2021 BGM DRUMS ALERT.ogg")

func _ready():
	fore_player.stream = _title_bgm
	back_player.stream = _alert_bgm
	fore_player.play()

func play_titlescreen_bgm():
	back_player.stop()
	if not fore_player.stream.resource_path.get_file().get_basename() == "GHGO2021 TITLE redux":
		fore_player.stop()
		fore_player.stream = _title_bgm
		fore_player.play()

func play_level_bgm():
	fore_player.stop()
	fore_player.stream = _level_bgm
	fore_player.play()

func play_alert_bgm():
	# Too much lag when seeking then playing, we were like 3 seconds off. So here we play and then seek
	# Derpy but incredibly effective
	back_player.volume_db = -80.0
	back_player.play()
	back_player.seek(fore_player.get_playback_position())
	back_player.volume_db = 0.0	
	$Timer.start()


func _on_Timer_timeout():
	$Tween.interpolate_property(back_player, "volume_db", 0, -80, 5, 1, Tween.EASE_IN, 0)
	$Tween.start()


func _on_Tween_tween_completed(_object, _key):
	back_player.stop()
