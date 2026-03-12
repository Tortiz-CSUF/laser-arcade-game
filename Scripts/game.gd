extends Node2D

## Game
# This is the main gameplay scene which will manage round progress, shape spawns,
# laser interactions, difficulty, timers, and transitions based on win/ lose conditions.

## Preloads
const ShapeScene := preload("res://Scenes/shape.tscn")

## REFs to shape types
const ShapeScript := preload("res://Scripts/shape.gd")
const Type = ShapeScript.Type

## Round config
# each round will define its duration, spawn rate, and fall speed
# also determines shape size, and shape type probabilities.
# wieghts[pos_circle, pos_diamond, pos_start, neg_tri, neg_hex, bomb, shield, frnezy]
const ROUNDS := {
	1: {
		"duration": 30.0,
		"spawn_interval": 1.0,
		"speed_min": 100.0,
		"speed_max": 200.0,
		"shape_size": 22.0,
		"weights": [30, 20, 0, 12, 0, 10, 4],
	},
	
	2: {
		"duration": 35.0,
		"spawn_interval": 0.7,
		"speed_min": 150.0,
		"speed_max": 300.0,
		"shape_size": 22.0,
		"weights": [22, 16, 10, 14, 10, 14, 6, 6],
	},
	
	3: {
		"duration": 40.0,
		"spawn_interval": 0.45,
		"speed_min": 200.0,
		"speed_max": 400.0,
		"shape_size": 22.0,
		"weights": [14, 12, 10, 16, 14, 18, 7, 7],
	},
}

## Node REFs
# gameplay
@onready var shape_container: Node2D = $ShapeContainer
@onready var laser: Area2D = $Laser
@onready var spawn_timer: Timer = $SpawnTimer

# HUD
@onready var round_label: Label = $HUD/Round
@onready var timer_label: Label = $HUD/Timer
@onready var score_label: Label = $HUD/Score
@onready var high_score_label: Label = $HUD/Highscore
@onready var multiplier_label: Label = $HUD/Multiplier
@onready var shield_indicator: Label = $HUD/ShieldIndicator
@onready var frenzy_indicator: Label = $HUD/FrenzyIndicator

# heart health
@onready var hearts: Array[TextureRect] = [
	$HUD/HeartsContainer/Heart1,
	$HUD/HeartsContainer/Heart2,
	$HUD/HeartsContainer/Heart3,
]

# end game condition overlays
@onready var round_announce: Label = $HUD/RoundAnnounce
@onready var game_over_overlay: ColorRect = $HUD/GameOverOverlay
@onready var game_over_score: Label =$HUD/GameOverOverlay/GameOverScore
@onready var victory_overlay: ColorRect = $HUD/VictoryOverlay
@onready var victory_score: Label = $HUD/VictoryOverlay/VictoryScore
@onready var victory_high_score: Label = $HUD/VictoryOverlay/VictoryHighScore

# game state vars
var round_time_left: float = 0.0			# secs left in round
var is_playing: bool = false				# true when active gameplay
var is_game_over: bool = false				# true when all live depleted
var is_between_rounds: bool = false			# true during transitions
var current_round_cfg: Dictionary = {}		# config for active round	

# effect timers
var shield_time_left: float = 0.0			# secs for shield left
var frenzy_time_left: float = 0.0			# secs for frenzy left



func _ready() -> void:
	# reset each new game
	GameManager.reset()
	
	# Connects GameManager signals -> HUD
	GameManager.lives_changed.connect((_on_lives_changed))
	GameManager.score_chagned.connect(_on_score_chagned)
	GameManager.multiplier_changed.connect(_on_multiplier_changed)
	
	# Other Signal connections
	laser.shape_zapped.connect(_on_shape_zapped)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# populate HUD with starting vals
	_update_hud()
	_update_hearts()
	
	# start round 1
	await  get_tree().create_timer(0.4).timeout
	_start_round(1)
	

func _process(delta: float) -> void:
	# updates round timer, effect timers and indicators
	if not is_playing:
		return
	
	# round timer
	if round_time_left <= 0.0:
		_end_round()
		return
		
	# shield timer
	if shield_time_left > 0.0:
		shield_time_left -= delta
		shield_indicator.text = "SHIELD: " + str(ceili(shield_time_left)) + "s"
		if shield_time_left <= 0.0:
			GameManager.deactivate_sheild()
			shield_indicator.text = ""
			
	# frenzy timer
	if frenzy_time_left > 0.0:
		frenzy_time_left -= delta
		frenzy_indicator.text = "FRENZY: " + str(ceili(frenzy_time_left)) + "s"
		if frenzy_time_left <= 0.0:
			GameManager.deactivate_sheild()
			frenzy_indicator.text = ""
			# restores normal spawn rate
			spawn_timer.wait_time = current_round_cfg["spawn_interval"]


func _unhandled_input(event: InputEvent) -> void:
	# restart/ quit input on game over/ victory overlays
	if not event.is_action_pressed("ui_accept") and not event.is_action_pressed("ui_cancel"):
		return 
		
	if is_game_over or victory_overlay.visible:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	
## Round management
func _start_round(round_num: int) -> void:
	# sets round data
	GameManager.set_round(round_num)
	current_round_cfg = ROUNDS[round_num]
	round_time_left = current_round_cfg["duration"]
	
	# HUD updates
	round_label.text = "ROUND " + str(round_num)
	_update_hud()
	
	# displays round at start
	is_between_rounds = true
	round_announce.text = "ROUND " + str(round_num)
	round_announce.visible = true
	await  get_tree().create_timer(1.8).timeout
	round_announce.visible = false
	is_between_rounds = false
	
	# allow gameplay
	is_playing = true
	laser.can_fire = true
	spawn_timer.wait_time = current_round_cfg["spawn_interval"]
	spawn_timer.start()	

func _end_round() -> void:
	# at end of round, stops shape spawns and decide transition logic
	is_playing = false	
	laser.can_fire = false
	spawn_timer.stop()
	
	# clear shapes and special effects
	_clear_shapes()
	_clear_effects()
	
	if GameManager.current_round < 3:
		# short pause for next round
		await get_tree().create_timer(1.2).timeout
		_start_round(GameManager.current_round + 1)		
	else:
		# game complete
		await get_tree().create_timer(1.0).timeout
		_show_victory()
		
	
## Shape spawns
func _on_spawn_timer_timeout() -> void:
	# creates new shape with randoms weights/ speed
	var shape_instance := ShapeScene.instantiate()
	var chosen_type := _pick_weighted_type()
	var spd := randf_range(current_round_cfg["speed_min"], current_round_cfg["speed_max"])
	
	shape_instance.setup(chosen_type, spd, current_round_cfg["shape_size"])
	
	var margin := 40.0
	shape_instance.position = Vector2(randf_range(margin, 1280.0 - margin), -40.0)
	
	shape_container.add_child(shape_instance)
	
	
	
func _pick_weighted_type() -> int:
	# selects a shape type using round weights | more weight = more likely 
	var weights: Array = current_round_cfg["weights"]
	
	# double bomb weight for bomb frenzy
	if GameManager.frenzy_active:
		weights = weights.duplicate()
		weights[5] = weights[5] * 2		#bomb at index 5
		
	# determines total weight and picks random val
	var total := 0
	for w in weights:
		total += w
	var roll := randi() % total
	var cumulative := 0
	
	for i in weights.size():
		cumulative += weights[i]
		if roll < cumulative:
			return i
			
	return 0
	

## Zap Handler
func _on_shape_zapped(shape: Area2D) -> void:
	# when a shape is zapped, called by laser signal to use correct handler
	match shape.shape_type:
		Type.POSITIVE_CIRCLE, Type.POSITIVE_DIAMONOD, Type.POSITIVE_STAR:
			GameManager.add_score(shape.point_value)
			
		Type.BOMB:
			var game_over : = GameManager.lose_life()
			if game_over:
				_show_game_over()
				
		Type.BOMB_SHIELD:
			# 5 sec shield 
			shield_time_left = 5.0
			GameManager.activate_sheild(5.0)
			
		Type.BOMB_FRENZY:
			# 8 sec bomb frenzy
			frenzy_time_left = 8.0
			GameManager.activate_frenzy(8.0)
			# creates more frequent spawns
			spawn_timer.wait_time = current_round_cfg["spawn_interval"] * 0.5
			
			
## Game Over
func  _show_game_over() -> void:
	# stops gameplay and shows game over overlay
	is_playing = false
	is_game_over = true
	laser.can_fire = false
	spawn_timer.stop()
	
	# checks if new high score achieved
	GameManager.check_high_score()
	
	game_over_score.text = "SCORE: " + str(GameManager.score)
	game_over_overlay.visible = true
	

## Victory
func _show_victory() -> void:
	# show end game overlay with game score and high score
	var is_new_high := GameManager.check_high_score()
	
	victory_score.text = "FINAL SCORE: " + str(GameManager.score)
	
	if is_new_high:
		victory_high_score.text = "NEW HIGH SCORE! "
	else: 
		victory_high_score.text = "HGIH SCORE: " + str(GameManager.high_score)
		
	victory_overlay.visible = true
	

## HUD Managment
func _update_hud() -> void:
	score_label.text = "SCORE: " + str(GameManager.score)
	high_score_label.text = "HIGH SCORE: " + str(GameManager.high_score)
	multiplier_label.text = "X " + str(GameManager.multiplier)
	round_label.text = "ROUND " + str(GameManager.current_round)

func _on_score_chagned(new_score: int) -> void:
	score_label.text = "SCORE: " + str(new_score)
	
func _on_lives_changed(_new_lives: int) -> void:
	_update_hearts()
	
func _on_multiplier_changed(new_multiplier: int) -> void:
	multiplier_label.text = "X " + str(new_multiplier)
	
	# will flash to indicate value multi increase
	if new_multiplier > 1:
		round_announce.text = "X " + str(new_multiplier) + "MULTIPLIER!"
		round_announce.visible = true
		await get_tree().create_timer(1.0).timeout
		if not is_between_rounds:
			round_announce.visible = false
				
				
func _update_hearts() -> void:
	# uses atlas to set filled or empty hearts
	for i in hearts.size():
		var tex: AtlasTexture = hearts[i].texture as AtlasTexture
		if tex: 
			if i < GameManager.lives:
				tex.region = Rect2(0, 0, 16, 16)		# filled
			else:
				tex.region = Rect2(16, 0, 16, 16)		# empty

## Helpers
func _clear_shapes() -> void:
	for child in shape_container.get_children():
		child.queue_free()
		
func _clear_effects() -> void:
	shield_time_left = 0.0
	frenzy_time_left = 0.0
	shield_indicator.text = ""
	frenzy_indicator.text = ""
	GameManager.deactivate_sheild()
	GameManager.deactivate_frenzy()
	
	
