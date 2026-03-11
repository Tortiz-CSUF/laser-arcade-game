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
const BOM_RIM: Color = Color(1.0, 0.45, 0.0)			# accent color (orange)
const SHIELD_COL: = Color(0.25, 0.55, 1.0)			# blue shield
const FRENZY_COL: = Color(0.72, 0.1, 0.95)			# purple frenzy





func _process(delta: float) -> void:
	pass
