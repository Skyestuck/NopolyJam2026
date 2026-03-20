extends Node

var score: float = 0.0
var score_rate := 1
var score_multiplier : = 1
var zombie_count = 1
var player_alive: bool = true
var master_volume = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_alive:
		score += ((score_rate * zombie_count) * score_multiplier) * delta
