extends Control

### Instructions
# Displays how the game works, with rules, controls, and object details.

###

# Node refs
@onready var content: VBoxContainer = $InstructionsContainer

# Scrolling 
var scroll_offset: float = 0.0		## tracks scroll position
const SCROLL_STEP := 40.0 			## Scroll speed
const MAX_SCROLL := 350.0 			## Bottom of page for scroll

# Text Color (Used to section)
const HEAD_COLOR := Color(1.0, 0.25, 0.25)		# section headers
const SUBHEAD_COLOR := Color(1.0, 1.0, 0.2)		# sub headers
const TEXT_COLOR := Color(0.82, 0.82, 0.82)		# body text
const NEG_COLOR := Color(1.0, 0.2, 0.45)			# negative shapes
const BOMB_COLOR := Color(1.0, 0.45, 0.0)			# bombs
const SHIELD_COLOR := Color(0.3, 0.6, 1.0)		# shield special 
const FRENZY_COLOR := Color(0.72, 0.15, 0.95)		# frenzy bonus


func _ready() -> void:
	pass # Replace with function body.

func _build_instructions() -> void:
	## All instruction info will go here 
	
	# Title 
	_add_heading("HOW TO PLAY", HEAD_COLOR, 32)
	#_add_spacer(6)

# Input
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	elif event.is_action_pressed("ui_up"):
		scroll_offset = maxf(scroll_offset - SCROLL_STEP, 0.0)
		content.position.y = -scroll_offset + 30.0
	elif event.is_action_pressed("ui_down"):
		scroll_offset = minf(scroll_offset + SCROLL_STEP, MAX_SCROLL)
		content.position.y = -scroll_offset + 30.0

	
## Helper Functions 
func _add_heading(text: String, color: Color, size: int) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	content.add_child(lbl)
	
func _add_line(text: String, color: Color = TEXT_COLOR) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 21)
	lbl.add_theme_color_override("font_color", color)
	content.add_child(lbl)
	
func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	content.add_child(spacer)
	
	
	
	
	
