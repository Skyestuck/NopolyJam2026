extends Node2D

var ZombieScene := preload("res://Scenes/Zombie.tscn")
@onready var cam := $Camera2D
#could replace with
#load("res://Scenes/Zombie.tscn")
#if I run into issues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/GameOver.visible = false
	Score.score = 0.0
	Score.score_rate = 1
	Score.score_multiplier = 1
	Score.zombie_count = 1
	Score.player_alive = true # Replace with function body.
	$HighIntPlayer.volume_db = -20.0
	$MedIntPlayer.volume_db = -80.0
	$LowIntPlayer.volume_db = -80.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#debug options
	#if Input.is_action_just_pressed("Debug1"):
		#print("All Players: ",get_tree().get_nodes_in_group("all_players"))
		#print("THE Player: ",get_tree().get_nodes_in_group("player"))
	#
	#if Input.is_action_just_pressed("Action1"):
		#var Zombie = ZombieScene.instantiate()
		#Zombie.position = get_global_mouse_position()
		#add_child(Zombie)
	
	#Actual Game Functionality
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		cam.global_position = players[0].global_position
		cam.zoom = Vector2i(2,2)
		
		
	var zombies = get_tree().get_nodes_in_group("all_players")
	if zombies.size() == 0:
		game_over()
	
	var player = get_tree().get_nodes_in_group("player")
	if player.size() == 0 and zombies.size() != 0:
			var new_player = zombies[0]
			new_player.add_to_group("player")
			new_player.get_node("AudioListener2D").current = true
			#print("Assigned new player:", new_player.name)
	
	#Music Control
	
	if Score.zombie_count == 1:
		$HighIntPlayer.volume_db = -20.0
		$MedIntPlayer.volume_db = -80.0
		$LowIntPlayer.volume_db = -80.0
		print("play high")
	elif Score.zombie_count < 5:
		$HighIntPlayer.volume_db = -80.0
		$MedIntPlayer.volume_db = -20.0
		$LowIntPlayer.volume_db = -80.0
		print("play medium")
	elif Score.zombie_count >= 5:
		$HighIntPlayer.volume_db = -80.0
		$MedIntPlayer.volume_db = -80.0
		$LowIntPlayer.volume_db =-20.0
		print("play low")
	
	



func game_over():
	Score.player_alive = false
	$CanvasLayer/GameOver.visible = true
	print("GAME OVER!")
	#pass


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.
