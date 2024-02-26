extends Node2D

var button = preload("res://button.tscn")
@onready var timer = get_node("Timer")
@onready var question_label = get_node("CanvasLayer/MainVBox/QuestionLabelVar")
@onready var result_label = get_node("CanvasLayer/MainVBox/ResultLabel")
@onready var score_label = get_node("CanvasLayer/ScoreLabel")
@onready var button_container = get_node("CanvasLayer/MainVBox/HBoxContainer")
@onready var menu_box = get_node("CanvasLayer/MenuVBox")
@onready var flip_toggle_button = get_node("CanvasLayer/MenuVBox/FlipCheckButton")
@onready var hira1_toggle_button = get_node("CanvasLayer/MenuVBox/Hira1CheckButton")
@onready var hira2_toggle_button = get_node("CanvasLayer/MenuVBox/Hira2CheckButton")
@onready var hira3_toggle_button = get_node("CanvasLayer/MenuVBox/Hira3CheckButton")
@onready var kata1_toggle_button = get_node("CanvasLayer/MenuVBox/Kata1CheckButton")
@onready var kata2_toggle_button = get_node("CanvasLayer/MenuVBox/Kata2CheckButton")

var btns = []
var correct_answer: String
var score_correct: int = 0
var score_total: int = 0
var num_choices: int = 4

func _ready() -> void:
	for btn in btns:
		btn.queue_free()
	btns = []
	
	for i in num_choices:
		var btn_instance = button.instantiate()
		btn_instance.pressed.connect(self._on_button_pressed.bind(i))
		btns.append(btn_instance)
		button_container.add_child(btn_instance)
	
	menu_box.visible = false
	randomize()
	if not GlobalRef.hiragana: return
	new_question(flip_toggle_button.button_pressed)
	update_score()

func new_question(is_char_question: bool = true) -> void:
	var toggled_char_sets = get_toggled_char_sets()
	var question_list = generate_question_list(toggled_char_sets)
	var answer_list = generate_answer_list(toggled_char_sets)
	if not question_list or not question_list: return
	
	var d
	if is_char_question:
		d = generate_question_answer(question_list, answer_list, num_choices)
	else:
		d = generate_question_answer(answer_list, question_list, num_choices)
	populate_new_question(d['question'], d['options'])
	correct_answer = d['answer']

func generate_question_list(char_sets: Array = []) -> Array:
	var questions = []
	for i in GlobalRef.notes.size():
		if GlobalRef.notes[i] in char_sets:
			questions.append(GlobalRef.hiragana[i])
	return questions

func generate_answer_list(char_sets: Array = []) -> Array:
	var answers = []
	for i in GlobalRef.notes.size():
		if GlobalRef.notes[i] in char_sets:
			answers.append(GlobalRef.romaji[i])
	return answers

func populate_new_question(question: String = "", options: Array = ["","","",""]) -> void:
	result_label.text = ""
	question_label.text = question
	for i in btns.size():
		btns[i].text = options[i]

func get_toggled_char_sets() -> Array:
	var toggled = []
	if hira1_toggle_button.button_pressed: toggled.append('hira1')
	if hira2_toggle_button.button_pressed: toggled.append('hira2')
	if hira3_toggle_button.button_pressed: toggled.append('hira3')
	if kata1_toggle_button.button_pressed: toggled.append('kata1')
	if kata2_toggle_button.button_pressed: toggled.append('kata2')
	return toggled

func generate_question_answer(questions: Array, answers: Array, num_options: int = 4) -> Dictionary:
	var options_idx = n_numbers_without_replacement(questions.size(), num_options)
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

func update_score() -> void:
	var pct = 0.0
	@warning_ignore("integer_division")
	if not score_total == 0: pct = (100*score_correct/score_total)
	score_label.text = "Score: %s/%s (%s%%)" % [score_correct, score_total, pct]

func reset_score() -> void:
	score_correct = 0
	score_total = 0
	update_score()

func _on_button_pressed(button_idx: int) -> void:
	if result_label.text != "": return
	var result = validate_answer(button_idx)
	
	if result == "":
		result_label.text = GlobalRef.CORRECT_TEXT
		score_correct += 1
	else:
		result_label.text = GlobalRef.INCORRECT_TEXT + correct_answer
	
	score_total += 1
	update_score()
	timer.start()

func _on_timer_timeout() -> void:
	new_question(flip_toggle_button.button_pressed)

func _on_check_button_pressed():
	new_question(flip_toggle_button.button_pressed)

func _on_menu_button_pressed():
	menu_box.visible = !menu_box.visible

func _on_show_score_check_button_toggled(toggled_on):
	score_label.visible = toggled_on
