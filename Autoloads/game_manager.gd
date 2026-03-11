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
signal shield_ended						## Emits when shield wears off
signal frenzy_started(duration: float)	## Emits bomb-frenzy penalty
signal frenzy_ended						## Emits when frenzy has ended

## State Vars
var score: int = 0					## Players current score in round
var high_score: int = 0				##	Best score across all sessions.
var lives: int = 3					## Lives remaining
var current_round: int = 1			## Current round player is in 
var multiplier: int = 1				## Point multiplier
var shield_active: bool = false		## true: bomb hit cost no life
var frenzy_active : bool = false	## true: bombs spawn 2x


## Constants
const MAX_LIVES := 3
# DEV NOTE: MAKE SURE TO INSERT FILE PATH THAT HOLDS LIFE DATA HERE!!!
const SAVE_PATH := "[INSERT FILE PATH LATER]"


func _ready() -> void:
	# load high score at start of game
	load_high_score()

## Score 	
func add_score(points: int) -> void:
	# Adds score, and applies multiplier
	score += points * multiplier
	if score < 0:
		score = 0
	score_chagned.emit(score)

func check_high_score() -> bool:
	## Compares current score against high score
	## if new record: save to file 
	if score > high_score:
		high_score = score
		save_high_score()
		return true 
	return false 

## Lives
func lose_life() -> bool:
	## Decrements lives, returns true if player out of lives
	## Accounts for active shield logic 
	if shield_active:
		return false
	lives -= 1
	if lives < 0:
		lives = 0
	lives_changed.emit(lives)
	return lives <= 0
	
func gain_life() -> void:
	## Add extra life, MAX_LIVES capped
	if lives < MAX_LIVES:
		lives += 1
		lives_changed.emit(lives)

## Rounds
func set_round(round_num: int) -> void:
	## Sets the current round and updates multiplier
	## so, round 1 = x1, round 2 = x2, ..,	
	current_round = round_num
	match round_num:
		1: multiplier = 1
		2: multiplier = 2
		3: multiplier = 3
	multiplier_changed.emit(multiplier)
	
## Special Effects
func activate_sheild(duration: float) -> void:
	## turns bomb sheild on and runs a timer
	shield_active = true
	shield_started.emit(duration)

func deactivate_sheild() -> void:
	## truns off bomb shield when timer runs out
	shield_active = false
	shield_ended.emit()

func activate_frenzy(duration: float) -> void:
	## Turns on the double bomb rate frenzy and timer
	frenzy_active = true
	frenzy_started.emit(duration)

func deactivate_frenzy() -> void:
	# end the bomb frenzy 
	frenzy_active = false
	frenzy_ended.emit()

## Persistent Data
func save_high_score() -> void:
	## Write the high score as 32-bit int to local file 
	## Will use Godot user:// path
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_high_score() -> void:
	## Called in _ready() at game launch
	## Reads high score from save files, if it exists
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
