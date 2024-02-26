extends Node2D

@onready var timer = get_node("Timer")
@onready var question_label = get_node("CanvasLayer/VBoxContainer/QuestionLabelVar")
@onready var result_label = get_node("CanvasLayer/VBoxContainer/ResultLabel")
@onready var btn_a = get_node("CanvasLayer/VBoxContainer/HBoxContainer/ButtonA")
@onready var btn_b = get_node("CanvasLayer/VBoxContainer/HBoxContainer/ButtonB")
@onready var btn_c = get_node("CanvasLayer/VBoxContainer/HBoxContainer/ButtonC")
@onready var btn_d = get_node("CanvasLayer/VBoxContainer/HBoxContainer/ButtonD")
@onready var btns = [btn_a, btn_b, btn_c, btn_d]
@onready var flip_toggle_button = get_node("CanvasLayer/FlipCheckButton")
var correct_answer: String

func _ready() -> void:
	randomize()
	if not GlobalRef.hiragana: return
	new_question(flip_toggle_button.button_pressed)

func new_question(is_char_question: bool = true) -> void:
	var d
	if is_char_question:
		d = generate_question_answer(GlobalRef.hiragana, GlobalRef.romaji)
	else:
		d = generate_question_answer(GlobalRef.romaji, GlobalRef.hiragana)
	populate_new_question(d['question'], d['options'])
	correct_answer = d['answer']

func populate_new_question(question: String = "", options: Array = ["","","",""]) -> void:
	result_label.text = ""
	question_label.text = question
	btn_a.text = options[0]
	btn_b.text = options[1]
	btn_c.text = options[2]
	btn_d.text = options[3]

func generate_question_answer(questions: Array, answers: Array) -> Dictionary:
	var options_idx = n_numbers_without_replacement(questions.size(), 4)
	var ans_idx = options_idx[0]
	var options = []
	for i in options_idx:
		options.append(answers[i])
	options.shuffle()
	var question = questions[ans_idx]
	var answer = answers[ans_idx]
	return {
		"question": question,
		"answer": answer,
		"options": options,
	}

func n_numbers_without_replacement(num_elements: int = 100, num_picks: int = 1) -> Array:
	var nums = []
	while num_picks > 0:
		var num = randi() % num_elements
		if num not in nums:
			nums.append(num)
			num_picks -= 1
	return nums

func validate_answer(picked: int) -> String:
	var picked_answer = btns[picked].text
	var is_answer_correct = correct_answer == picked_answer
	
	var result = "" if is_answer_correct else correct_answer
	return result

func _on_button_pressed(button_idx: int) -> void:
	if result_label.text != "": return
	var result = validate_answer(button_idx)
	
	if result == "":
		result_label.text = GlobalRef.CORRECT_TEXT
	else:
		result_label.text = GlobalRef.INCORRECT_TEXT + correct_answer
	
	timer.start()

func _on_timer_timeout() -> void:
	new_question(flip_toggle_button.button_pressed)

func _on_flip_check_button_toggled(toggled_on) -> void:
	new_question(flip_toggle_button.button_pressed)
