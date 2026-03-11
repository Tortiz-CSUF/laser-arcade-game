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
@onready var game_over_overlay: Label = $HUD/GameOverOverlay
@onready var game_over_score: Label =$HUD/GameOverOverlay/GameOverScore
@onready var victory_overlay: Label = $HUD/VictoryOverlay
@onready var victory_score: Label = $HUD/VictoryOverlay/VictoryScore
@onready var victory_high_score: Label = $HUD/VictoryOverlay/VictoryHighScore


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
