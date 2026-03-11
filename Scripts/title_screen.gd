extends Control
### TitleScreen
# Title screen that appears at game start. 
# Can be navigated with keyboard. 
# Menu options:
# 	- Start
#	- How to play
# Displays high score 

## Node refs
@onready var play_label: Label = $Play
@onready var instructions_label = $Instructions
@onready var high_score_label = $HighScore

## Title Menu state
var selected_index: int = 0		# 0 = play, 1 = how to play
var blink_time: float = 0.0		## arcade style blinking 

## User color highlights
const SELECTED_COLOR := Color(1.0, 1.0, 0.2)	#bright yellow
const UNSELECTED_COLOR := Color(0.85, 0.85, 0.85) #light grey 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Read the latest highscore to display
	high_score_label.text = "HIGH SCORE: " + str(GameManager.high_score)
	
	## default highlited selection
	_update_selection()
	
func _process(delta: float) -> void:
	## update selected label with blink  and animated arrows
	blink_time += delta
	var pulse := 0.6 + sin(blink_time * 5.0) * 0.4
	if selected_index == 0:
		play_label.modulate.a = pulse
		instructions_label.modulate.a = 1.0
	else:
		play_label.modulate.a = 1.0
		instructions_label.modulate.a = pulse
	
	#var show_arrow := fmod(blink_time, 0.6) < 0.4
	
	#play_label.text = _format_item("PLAY", 0, show_arrow)
	#instructions_label.text = _format_item("INSTRUCTIONS", 1, show_arrow)


## Input
func _unhandled_input(event: InputEvent) -> void:
	##
	if event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + 2) % 2
		_update_selection()
		blink_time = 0.0
	elif event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % 2
		_update_selection()
		blink_time = 0.0
	elif  event.is_action_pressed("ui_accept"):
		_confirm_selection()

## Helper functions
###func _format_item(base_text: String, index: int, show_arow: bool) -> String:
	## Adds blinking and arcade style arrows on selected option
	#if index == selected_index and show_arow:
		#return "> " + base_text + " <"
	#return base_text

func _update_selection() -> void:
	## applies highlight when options is selected, and grey to unselected.
	play_label.add_theme_color_override("font_color", 
		SELECTED_COLOR if selected_index == 0 else UNSELECTED_COLOR)
	instructions_label.add_theme_color_override("font_color", 
		SELECTED_COLOR if selected_index == 1 else UNSELECTED_COLOR)
	
func _confirm_selection() -> void:
	## changes the scene based on menu option
	### NOTE: NEED TO INSERT SCENES PATHS TO OPTION LOGIC
	match selected_index:
		0: 
			get_tree().change_scene_to_file("[INSERT LEVEL PATH HERE]")
		1: 
			get_tree().change_scene_to_file("res://Scenes/instructions.tscn")
	
