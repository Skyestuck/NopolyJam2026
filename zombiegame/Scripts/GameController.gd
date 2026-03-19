extends Node2D

var ZombieScene := preload("res://Scenes/Zombie.tscn")
@onready var cam := $Camera2D
#could replace with
#load("res://Scenes/Zombie.tscn")
#if I run into issues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Debug1"):
		print("All Players: ",get_tree().get_nodes_in_group("all_players"))
		print("THE Player: ",get_tree().get_nodes_in_group("player"))
	
	if Input.is_action_just_pressed("Action1"):
		var Zombie = ZombieScene.instantiate()
		Zombie.position = get_global_mouse_position()
		add_child(Zombie)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		cam.global_position = players[0].global_position
		
		
	var zombies = get_tree().get_nodes_in_group("all_players")
	if zombies.size() == 0:
		game_over()
	
	var player = get_tree().get_nodes_in_group("player")
	if player.size() == 0 and zombies.size() != 0:
			var new_player = zombies[0]
			new_player.add_to_group("player")
			#print("Assigned new player:", new_player.name)
	



func game_over():
	print("GAME OVER!")

	#pass
