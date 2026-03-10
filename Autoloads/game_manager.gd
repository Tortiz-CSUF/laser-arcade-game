extends Node

### (GameManager Autoload) ###
# Serves as a global singleton that tracks all game states. 
# Stored Info:
# score, high scores, lives, progression, 
# point multipliers

###

## Signals - Used for emmitting data to scenes 
signal lives_changed(new_lives: int)	## Emits player life + or -
signal score_chagned(new_score: int)	## Emits point loss/ addition
signal multiplier_changed(new_multiplier: int)	## Emits point multiplier updates
signal shield_started(duration: float)	## Emits bomb-immunity shield
signal sheild_ended						## Emits when shield wears off
signal frenzy_started(duration: float)	## Emits bomb-frenzy penalty
signal frenzy_ended						## Emits when frenzy has ended

## State Vars
var score: int = 0					## Players current score in round
var high_score: int = 0				##	Best score across all sessions.
var lives: int = 3					## Lives remaining
var current_round: int = 1			## Current round player is in 
var multiplier: int = 1				## Point multiplier
var sheild_active: bool = false		## true: bomb hit cost no life
var frenzy_active : bool = false	## true: bombs spawn 2x


## Constants
const MAX_LIVES := 3
# DEV NOTE: MAKE SURE TO INSERT FILE PATH THAT HOLDS LIFE DATA HERE!!!
const SAVE_PATH := "[INSERT FILE PATH LATER]"


func _ready() -> void:
	pass # Replace with function body.
