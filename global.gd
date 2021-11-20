extends Node

var game_state = {
	"levels_unlocked": 0
}

func save_game():
	var save_file = File.new()
	save_file.open("user://bug_sneak_game.save", File.WRITE)
	
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
