extends Area2D

### Shape
# Falling game objects that the player can zap using the laser.
# Each shape will have unique types that determine color/shape and point value
# or penalties.
# Shapes will be spawned and fall and randomized speeds. 

###

## Shape Types
# enum used to define every shape

enum Type 
{
	POSITIVE_CIRCLE, 			# Circle worth +10 to +30
	POSITIVE_DIAMONOD,			# Diamond worth +20 to +40
	POSITIVE_STAR,				# start worth +30 to +50
	NEGATIVE_TRIANGLE,			# triangle, worth -10 to -20
	NEGATIVE_HEXAGON,			# hexagon worht -20 to -30
	BOMB,						# bomb that costs a life
	BOMB_SHIELD,				# grants temp bomb immunity
	BOMB_FRENZY,				# doubles bomb spawn rate
}

## Vars
var shape_type: Type = Type.POSITIVE_CIRCLE			# ID of shape
var point_value: int = 0							# shape point value
var speed: float = 150.0							# fall speed of shape
var size: float = 22.0								# size of shape
var is_zapped: bool = false							# tacks zapped shapes
var color: Color = Color.WHITE						# base color of shapes
var time_alive: float = 0.0							# for pulse anim

## Shape Colors
const POS_COLORS: Array[Color] = [
	Color(0.2, 1.0, 0.4),			# green
	Color(0.2, 0.9, 1.0),			# teal/ cyan
	Color(1.0, 1.0, 0.2)			# yellow
	
]

const NEG_COLORS: Array[Color] = [
	Color(1.0, 0.15, 0.2),			# red 
	Color(1.0, 0.2, 0.7)			# magenta
	
]

const BOMB_BODY: Color = Color(0.35, 0.35, 0.35)		# body base color
const BOMB_RIM: Color = Color(1.0, 0.45, 0.0)			# accent color (orange)
const SHIELD_COL: = Color(0.25, 0.55, 1.0)			# blue shield
const FRENZY_COL: = Color(0.72, 0.1, 0.95)			# purple frenzy



## Shapes setup
func setup(type: Type, spd: float, sz: float = 22.0) -> void:
	# called by game script once instantiated
	# assigns shape type, speed, size, and picks random color/ value
	shape_type = type
	speed = spd
	size = sz
	
	# update collision radius to match visual shape
	$CollisionShape2D.shape.radius = size * 0.85
	
	match type:
		Type.POSITIVE_CIRCLE:
			point_value = [10, 20, 30].pick_random()
			color = POS_COLORS.pick_random()
		Type.POSITIVE_DIAMONOD:
			point_value = [20, 30, 40].pick_random()
			color = POS_COLORS.pick_random()
		Type.POSITIVE_STAR:
			point_value = [30, 40, 50].pick_random()
			color = POS_COLORS.pick_random()
			
		Type.NEGATIVE_TRIANGLE:
			point_value = [-10, -20].pick_random()
			color = NEG_COLORS.pick_random()
		Type.NEGATIVE_HEXAGON:
			point_value = [-20, -30].pick_random()
			color = NEG_COLORS.pick_random()
			
		Type.BOMB:
			point_value = 0
			color = BOMB_BODY
		Type.BOMB_SHIELD:
			point_value = 0
			color = SHIELD_COL
		Type.BOMB_FRENZY:
			point_value = 0
			color = FRENZY_COL
			
	# redraw so new shape renders new type/color
	queue_redraw()
	

## Shape fall logic and create/ destroy
func _process(delta: float) -> void:
	# fall down at assigned speed
	position.y += speed * delta
	time_alive += delta
	
	#pulsing for bombs and special effects
	if shape_type in [Type.BOMB, Type.BOMB_SHIELD, Type.BOMB_FRENZY]:
		var pulse_scale := 1.0 + sin(time_alive * 6.0) * 0.12
		scale = Vector2(pulse_scale, pulse_scale)
		
	# remove shape if bottom of screen is reached
	if position.y > 780:
		queue_free()
			
	
## Shape Zap
func zap() -> void:
	# called by laser to sap shape
	# will flash birght and remove shape
	
	if is_zapped:
		return
		
	is_zapped = true
	set_process(false)		#stop fall
	
	#flash -> fade away
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(6, 6, 6, 1), 0.06)
	tw.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.18)
	tw.tween_callback(queue_free)
	
	
## Drawing 
# each shape type will has their own draw function 

#func _draw() -> void:
	# create draw method for shape and draw point value on top
	#match shape_type:
		#$Type.POSITIVE_CIRCLE:
			
func _draw_circle() -> void:
	draw_circle(Vector2.ZERO, size, color)
	draw_arc(Vector2.ZERO, size, 0, TAU, 32, Color.WHITE, 2.0)
	
func _draw_diamond() -> void:
	var pts := PackedVector2Array([
		Vector2(0, -size), 
		Vector2(size, 0), 
		Vector2(0, size), 
		Vector2(-size, 0)
	])
	
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array(Array(pts) + [pts[0]]), Color.WHITE, 2.0)
	
func _draw_star() -> void:
	var pts := _star_points(size, size * 0.45, 5)
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array(Array(pts) + [pts[0]]), Color.WHITE, 2.0)
	
func _draw_triangle() -> void:
	# draws updside down triange
	var pts := PackedVector2Array([
		Vector2(-size, -size * 0.7),
		Vector2(size, -size *0.7),
		Vector2(0, size * 0.9)
	])
	
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array(Array(pts) + [pts[0]]), Color.WHITE, 2.0)
	
func _draw_hexagon() -> void:
	var pts := _polygon_points(size, 6)
	
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array(Array(pts) + [pts[0]]), Color.WHITE, 2.0)
	
func _draw_bomb() -> void:
	# bomb drawn as dark circle with orange outline, with a fuse and blinking spark
	
	# body
	draw_circle(Vector2.ZERO, size, BOMB_BODY)
	draw_arc(Vector2.ZERO, size, 0, TAU, 32, BOMB_RIM, 2.5)
	
	# Fuse
	var spark_alpha := 0.7 + sin(time_alive * 12.0) * 0.3
	draw_line(Vector2(0, -size), Vector2(4, -size -12), Color(0.708, 0.708, 0.708, 1.0), spark_alpha)
	
	# x marking
	draw_line(Vector2(-6, -4), Vector2(6, -4), BOMB_RIM, 2.0)
	draw_line(Vector2(0, -10), Vector2(0, 4), BOMB_RIM, 2.0)
	
	
func _draw_shield() -> void:
	# blue 6 point star with glow
	
	# glow
	draw_circle(Vector2.ZERO, size + 8, Color(color, 0.2))
	
	# body
	var pts := _star_points(size, size * 0.5, 6)
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array(Array(pts) + [pts[0]]), Color(0.7, 0.85, 1.0), 2.0)

func _draw_frenzy() -> void:
	# purple X shape with glow
	
	# glow
	draw_circle(Vector2.ZERO, size + 8, Color(color, 0.2))
	
	# body
	var w := 7.0
	draw_line(Vector2(-size, -size), Vector2(size, size), color, w)
	draw_line(Vector2(size, -size), Vector2(-size, size), color, w)
	# color contrast
	draw_line(Vector2(-size, -size), Vector2(size, size), Color.WHITE, 2.0)
	draw_line(Vector2(size, -size), Vector2(-size, size), Color.WHITE, 2.0)	
	
## Point labels
func _draw_label() -> void:
	# draw value label in mid shape
	var font := ThemeDB.fallback_font
	var fs := 13
	var text := ""
	
	if point_value > 0:
		text = "+" + str(point_value)
	elif point_value < 0:
		text = str(point_value)
	elif shape_type == Type.BOMB:
		text = "!" 
		fs = 16
	elif shape_type == Type.BOMB_SHIELD:
		text = "S"
		fs = 14
	elif shape_type == Type.BOMB:
		text = "F"
		fs = 14
		
	if text == "":
		return
		
	# center text
	var text_w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, Vector2(-text_w / 2.0, fs / 3.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)


## Shape Geometry Helpers
func _star_points(outer_r: float, inner_r: float, num_points: int) -> PackedVector2Array:
	# generates vertices for start points
	var pts := PackedVector2Array()
	var step := TAU / (num_points * 2)
	
	for i in num_points * 2:
		var angle := -PI / 2.0 + step * i
		var r := outer_r if i % 2 == 0 else inner_r
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
		
	return pts
	
func _polygon_points( r: float, sides: int) -> PackedVector2Array:
	# generates vetices for a polygon (hexagon in this case)
	var pts := PackedVector2Array()
	
	for i in sides:
		var angle := -PI / 2.0 + TAU / sides * i
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
	
	return pts
		
