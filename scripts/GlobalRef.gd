extends Node

var strings
var hiragana = []
var romaji = []
var INCORRECT_TEXT = "Wrong, the answer is: "
var CORRECT_TEXT = "Correct!"

func _ready():
	strings = csv_to_string_array("res://assets/hiragana-gojuon.txt")
	strings.pop_front()
	for row in strings:
		romaji.append(row[0])
		hiragana.append(row[1])
		
func csv_to_string_array(file_path: String) -> Array:
	var string_array = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var line = file.get_csv_line()
		string_array.append(line)
	return string_array

#func csv_to_string_array(file_path: String) -> Array:
	#var string_array = []
	#var file = ResourceLoader.load("res://assets/hiragana-gojuon.txt")
	#print(file)
	#return string_array