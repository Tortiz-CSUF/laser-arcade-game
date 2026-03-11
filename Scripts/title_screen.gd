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
	pass # Replace with function body.
	

## Input


## Helper functions


func _update_selection()

func _confirm_selection()	
