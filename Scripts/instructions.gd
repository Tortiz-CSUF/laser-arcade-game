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
const POS_COLOR := Color(0.2, 1.0, 0.2)			# positive shapes
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
	_add_spacer(6)
	
	# Controls
	_add_heading("CONTROLS", SUBHEAD_COLOR, 22)
	_add_line("Hold SPACE to activate the laser beam.")
	_add_line("The laser is a horizontal across the screen.")
	_add_line("While held, it zaps anything it touches.")
	_add_spacer(6)
	
	# Goal
	_add_heading("GOAL", SUBHEAD_COLOR, 22)
	_add_line("Colorful shapes will descend from above. Zap them to collect points!")
	_add_line("Aim for the highest score across three rounds.")
	_add_spacer(6)
	
	# Shapes
	_add_heading("SHAPES", SUBHEAD_COLOR, 22)
	_add_line(" Positive Points: Colors: (green, cyan, yellow) Shapes: (circles, diamonds, stars)", POS_COLOR)
	_add_line("		Worth +10 to +50 points (ZAP THESE!!!)")
	_add_line("Negative Points: Colors: (red/ magenta) Shapes: (triangles, hexagons)", NEG_COLOR)
	_add_line("		Worth -10 to -30 points (AVOID ZAPPING THESE!!!)")
	_add_line("Bombs: ", BOMB_COLOR)
	_add_line(		"Zapping a bomb will cost you a life! YOU GET 3 LIVES!!!")
	_add_spacer(6)
	
	# Bonus Shapes
	_add_heading("BONUS SHAPES")
	
	
	
	
	

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
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", color)
	content.add_child(lbl)
	
func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	content.add_child(spacer)
	
	
	
	
	
