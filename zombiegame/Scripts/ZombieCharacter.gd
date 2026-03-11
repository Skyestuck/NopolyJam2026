extends CharacterBody2D


@export var SPEED = 30.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input := Input.get_vector("MoveLeft","MoveRight","MoveUp","MoveDown")
	
	velocity = input * SPEED
	
	move_and_slide()
