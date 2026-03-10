extends CharacterBody2D


@export var SPEED = 300.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x := Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	var y := Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	var input := Vector2(x,y)
	
	velocity = input * SPEED
	
	move_and_slide()
