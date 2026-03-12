extends Node2D

var ZombieScene := preload("res://Scenes/Zombie.tscn")
#could replace with
#load("res://Scenes/Zombie.tscn")
#if I run into issues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Debug1"):
		var Zombie = ZombieScene.instantiate()
		Zombie.position = Vector2(randi_range(0,600),randi_range(0,300))
		add_child(Zombie)
	
	#pass
