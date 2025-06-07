class_name GameOver
extends Control

var score: int = 0
var scores: Array[Score] = []
var save_path: String = "user://high_scores.dat"


class Score:
	var value: int = 0
	var name: String = ""

	func _init(name_in: String = "", value_in: int = 0) -> void:
		value = value_in
		name = name_in.lstrip(" ").substr(0, 3).to_upper()

	func _to_string() -> String:
		return "%s - %d" % [name, value]


func run() -> void:
	($Score as Label).text = "SCORE: %d" % score
	visible = true
	scores = read_scores()
	list_scores()


func list_scores() -> void:
	var score_ledger: Control = $Scores
	for i: Control in score_ledger.get_children():
		i.queue_free()
	var score_entry_scene: PackedScene = load("res://scenes/score_entry.tscn")
	scores.sort_custom(func(a: Score, b: Score) -> bool: return a.value > b.value)
	var high_scores: Array[Score] = scores.slice(0, 8)
	for s: Score in high_scores:
		var score_entry: Control = score_entry_scene.instantiate()
		(score_entry.get_node("Name") as Label).text = s.name
		(score_entry.get_node("Score") as Label).text = str(s.value)
		score_ledger.add_child(score_entry)


func add_player_score() -> void:
	pass


func read_scores() -> Array[Score]:
	var scores_out: Array[Score] = []
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var new_score: Score = Score.new()
		new_score.name = file.get_line()
		new_score.value = int(file.get_line())
		scores_out.append(new_score)
		print(new_score)
	file.close()
	return scores_out


func save_scores() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	file.seek_end()
	for s: Score in scores:
		file.store_line(s.name)
		file.store_line(str(s.value))
	file.close()


func restart_game() -> void:
	Hacker.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()


func submit_score() -> void:
	($Submit as BaseButton).disabled = true
	var player_name: String = ($LineEdit as LineEdit).text
	var player_score: Score = Score.new(player_name, score)
	scores.append(player_score)
	save_scores()
	list_scores()


func edit_name(name_in: String) -> void:
	var line_edit := $LineEdit as LineEdit
	var regex: RegEx = RegEx.new()
	name_in = name_in.substr(0, 3).to_upper()
	regex.compile("[^A-Z]")
	var result: RegExMatch = regex.search(name_in)
	var cached_caret_pos: int = line_edit.caret_column
	if result:
		line_edit.text = regex.sub(name_in, "", true)
		line_edit.caret_column = cached_caret_pos
	else:
		line_edit.text = name_in
		line_edit.caret_column = cached_caret_pos
