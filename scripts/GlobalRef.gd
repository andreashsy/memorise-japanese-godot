extends Node

var strings
var hiragana = []
var romaji = []
var notes = []
var INCORRECT_TEXT = "間違っています、答えは: "
var CORRECT_TEXT = "正しい！"

func _ready():
	strings = csv_to_string_array("res://assets/hirakata.txt")
	strings.pop_front() # remove header
	for row in strings:
		romaji.append(row[0])
		hiragana.append(row[1])
		notes.append(row[2])
		
func csv_to_string_array(file_path: String) -> Array:
	var string_array = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var line = file.get_csv_line()
		string_array.append(line)
	return string_array
