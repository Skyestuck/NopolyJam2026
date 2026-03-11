extends CharacterBody2D


@export var SPEED = 60.0
@export var playerhp: int = 1
@export var lifetime: int = 0

signal died

func _ready():
	add_to_group("all_players")
	if get_tree().get_nodes_in_group("player").is_empty():
		add_to_group("player")
		print("I'm player")
	else:
		print("Player exists")

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_in_group("player"):
		var input := Input.get_vector("MoveLeft","MoveRight","MoveUp","MoveDown")
		lifetime += 1
		velocity = input * SPEED
		
		move_and_slide()
	else:
		pass

func take_damage(amount: int) -> void:
	playerhp -= amount
	print("HP: ", playerhp)
	if playerhp <= 0:
		print("A Zombie Died!")
		remove_from_group("player")
		queue_free()
		get_tree().call_group("all players", "_on_any_player_died", self)


func on_player_died() -> void:
	print("Player Died!")
	if is_queued_for_deletion(): return  # this is the dying node; skip
	if get_tree().get_nodes_in_group("player").is_empty():
		add_to_group("player")
		print("I'm the player now!")
	else:
		print("I'm Still Detecting A Player!")
		
func _on_any_player_died(dead: Node) -> void:
	if self == dead: return
	if !is_inside_tree(): return
	if get_tree().get_nodes_in_group("player").is_empty():
		add_to_group("player")
		print ("I'm the player now: ", name)
