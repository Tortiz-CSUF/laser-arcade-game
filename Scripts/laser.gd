extends Area2D

### Laser
# Horizontal beam the player activates with the SPACE bar. 
# When active, it detexts and zap shapes.
# When inactive, the path of the laser is indicated by a dotted line

###

## Signals
signal shape_zapped(shaped: Area2D)			# Emits(GameManager) when a shape is zappped

## States
var is_active: bool = false					# true: laser is firing
var can_fire: bool = false					# true when game starts
var overlapping_shapes: Array = []			# shapes within collision path

## Const for visuals
const BEAM_WIDTH := 1280.0								
const BEAM_HALF_HEIGHT := 5.0
const COLOR_ON := Color(1.0, 0.2 ,0.2, 0.95)			# red when firing/ active
const COLOR_OFF := Color(0.5, 0.15, 0.15, 0.35)		# dim red path
const GLOW_COLOR := Color(1.0, 0.3, 0.2, 0.25) 		# Glow for beam 
const CENTER_COLOR := Color(1.0, 0.8, 0.7, 1.0)		# laser core
const GUIDE_COLOR := Color(0.3, 0.1, 0.1, 0.2)		# beam edges when idle

func _ready() -> void:
	# Connect signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#SPACE input is checked each frame. 
	if not can_fire:
		if is_active:
			_deactivate()
		return

	if Input.is_action_pressed("shoot_laser") and not is_active:
		_activate()
	elif  not Input.is_action_pressed("shoot_laser") and is_active:
		_deactivate()
	
## Laser Activation
func _activate() -> void:
	# turns on laser
	is_active = true
	queue_redraw()
	
	# zap shapes in range
	for shape in overlapping_shapes.duplicate():
		_try_zap(shape)
		
func _deactivate() -> void:
	# turns laser off
	is_active = false
	queue_redraw()
			
## Collisions
func _on_area_entered(area: Area2D) -> void:
	# tracks shape if in laser path and zaps it
	if area.has_method("zap"):
		overlapping_shapes.append(area)
		if is_active:
			_try_zap(area)

func _on_area_exited(area: Area2D) -> void:
	# shape is not in laser path and was not zapped. stop tracking 
	overlapping_shapes.erase(area)

func _try_zap(shape: Area2D) -> void:
	# tries to zap a shape, if already zpped = skipped. 
	# Emits to adjust score and lives and bonus
	if shape.is_zapped:
		return 
	shape.zap()
	shape_zapped.emit(shape)
	overlapping_shapes.erase(shape)
		
## Laser Drawing 
func _draw() -> void:
	var half_w := BEAM_WIDTH / 2.0
	
	if is_active:
		_draw_active_beam(half_w)	
	else:
		_draw_inactive_beam(half_w)
		
func _draw_active_beam(half_w: float) -> void:
	draw_rect(Rect2(-half_w, -12, BEAM_WIDTH, 24), GLOW_COLOR)
	draw_rect(Rect2(-half_w, -6, BEAM_WIDTH, 12), Color(1.0, 0.25, 0.2, 0.35))
	draw_rect(Rect2(-half_w, -2, BEAM_WIDTH, 4), COLOR_ON)
	draw_line(Vector2(-half_w, 0), Vector2(half_w, 0), CENTER_COLOR, 1.5)
	
func _draw_inactive_beam(half_w: float) -> void:
	var dash_len := 18.0
	var gap_len := 12.0
	var x := -half_w
	
	# dashed line drawn 
	while x < half_w:
		var end_x := minf(x + dash_len, half_w)
		draw_line(Vector2(x, 0), Vector2(end_x, 0), COLOR_OFF, 2.0)
		x += dash_len + gap_len
		
		# laser path edge guide
		draw_line(Vector2(-half_w, -BEAM_HALF_HEIGHT), Vector2(half_w, -BEAM_HALF_HEIGHT), GUIDE_COLOR, 1.0)
		draw_line(Vector2(-half_w, BEAM_HALF_HEIGHT), Vector2(half_w, BEAM_HALF_HEIGHT), GUIDE_COLOR, 1.0)

	
