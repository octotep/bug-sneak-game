extends Node

var base_game_state = {
	"levels_unlocked": 0,
	"alert_counts": []
}

var game_state = base_game_state

var levels = [
	{
		"text": "Learning the Basics",
		"path": "res://src/levels/FirstLevel.tscn"
	},
	{
		"text": "Moving Along",
		"path": "res://src/levels/SecondLevel.tscn"
	},
	{
		"text": "Blocked Off",
		"path": "res://src/levels/ThirdLevel.tscn"
	},
	{
		"text": "Bugged Out",
		"path": "res://src/levels/FourthLevel.tscn"
	},
	{
		"text": "End in Sight",
		"path": "res://src/levels/FifthLevel.tscn"
	},
	{
		"text": "The Final Climb",
		"path": "res://src/levels/TheEnd.tscn"
	},
]

var current_level = -1

# Some light validation to make sure we're not saving bad data
func validate_game_state():
	
	# Make sure we have the right number of alert counts
	var alert_counts = game_state["alert_counts"]
	if alert_counts.size() > levels.size():
		alert_counts.resize(levels.size())
	while alert_counts.size() < levels.size():
		# We're not using resize here because that populates with nulls, we want -1 instead
		alert_counts.append(-1)

func save_game():
	var save_file = File.new()
	save_file.open("user://bug_sneak_game.save", File.WRITE)
	
	validate_game_state()
	
	save_file.store_line(to_json(game_state))

func does_save_file_exist():
	var save_file = File.new()
	return save_file.file_exists("user://bug_sneak_game.save")

func load_game():
	var save_file = File.new()
	if not does_save_file_exist():
		return
	
	save_file.open("user://bug_sneak_game.save", File.READ)
	game_state = parse_json(save_file.get_line())

# If we beat the current level, unlock the next one (level select screen prevents overflows)
func beat_level(alert_count):
	if (current_level + 1) == game_state["levels_unlocked"]:
		game_state["levels_unlocked"] += 1
	
	# Store the number of alerts, if it's lower than the current record
	var current_record = game_state["alert_counts"][current_level]
	if current_record == -1 or alert_count < current_record:
		game_state["alert_counts"][current_level] = alert_count
	
	save_game()

func get_alert_record(level):
	var record = -1

func did_win_game():
	if (current_level + 1) == len(levels):
		return true
	return false
