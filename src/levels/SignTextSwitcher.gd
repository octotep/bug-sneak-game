extends Node2D

func _ready():
	
	# We want different text if there's a touch screen,
	# because touch screens don't have a Z key (usually)
	if OS.has_touchscreen_ui_hint():
		$Sign.sign_text += "\n\nTap the zap button to start hacking."
	else:
		$Sign.sign_text += "\n\nPress the 'z' key to start hacking."
