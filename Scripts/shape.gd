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



func _process(delta: float) -> void:
	pass
	
	
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
		
