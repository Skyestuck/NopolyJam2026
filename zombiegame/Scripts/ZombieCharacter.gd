extends CharacterBody2D

@export var SPEED = 60.0
var default_speed = SPEED
@export var playerhp: int = 1
@export var lifetime: int = 0
var direction := Vector2.ZERO
var sprite_facing = get_direction(direction)

var wander_timer := 0.0
var wander_pause := 0.0
var wander_slowdown := 0.5 #wander at 50% speed

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
		sprite_facing = get_direction(input)
		lifetime += 1
		velocity = input * SPEED
		move_and_slide()
	else:
		if $TerrorRadius.has_overlapping_bodies():
			direction = (get_nearest_human($TerrorRadius.get_overlapping_bodies(), global_position) - global_position).normalized()
			velocity = direction * SPEED
		else:
			#wander
			#print ("Wander: ", wander_timer, " Pause: ", wander_pause)
			#print ("Direction: ", direction)
			if wander_timer <= 0: #wander is empty
				wander_timer = randf_range(3.0, 5.0)
				wander_pause = randf_range(1.0, 3.0)
				direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
			if not wander_pause <= 0: #pause is not emtpy
				SPEED = 0.0
				wander_pause -= delta
			elif wander_pause <= 0:
				SPEED = default_speed
				wander_timer -= delta
			velocity = direction * (SPEED * wander_slowdown)
		sprite_facing = get_direction(direction)
		move_and_slide()
	match sprite_facing:
		"none":
			$Sprite2D.frame = 0
			#print("Setting frame for:", sprite_facing)
		"down":
			$Sprite2D.frame = 0
			#print("Setting frame for:", sprite_facing)
		"up":
			$Sprite2D.frame = 3
			#print("Setting frame for:", sprite_facing)
		"left":
			$Sprite2D.frame = 1
			#print("Setting frame for:", sprite_facing)
		"right":
			$Sprite2D.frame = 2
			#print("Setting frame for:", sprite_facing)

func get_direction(vector: Vector2) -> String:
	if vector == Vector2.ZERO: 
		return "none"
	if vector.x > 0 and abs(vector.x) > abs(vector.y):
		return "right"
	elif vector.x < 0 and abs(vector.x) > abs(vector.y):
		return "left"
	elif vector.y > 0:
		return "down"
	else:
		return "up"


func get_nearest_human(humans: Array[Node2D], me: Vector2) -> Vector2:
	var nearest:= Vector2.ZERO
	var nearest_dist := INF
	for human in humans:
		var pos := human.global_position
		var d = me.distance_to(pos)
		if d < nearest_dist:
			nearest_dist = d
			nearest = pos
	return nearest

func take_damage(amount: int) -> void:
	playerhp -= amount
	print("HP: ", playerhp)
	if playerhp <= 0:
		print("A Zombie Died!")
		remove_from_group("player")
		queue_free()
		get_tree().call_group("all_players", "_on_any_player_died", self)

func _on_any_player_died(dead: Node) -> void:
	if self == dead: return
	if !is_inside_tree(): return
	await get_tree().process_frame
	if !is_inside_tree() or is_queued_for_deletion():
		return
	if get_tree().get_nodes_in_group("player").is_empty():
		add_to_group("player")
		print ("I'm the player now: ", name)

#func get_cured():
	#var HumanScene := load("res://Scenes/Human.tscn")
	#var Human = HumanScene.instantiate()
	#Human.position = global_position
	#get_parent().add_child(Human)
	#queue_free()
	#print ("I'm Cured!")


func get_cured() -> void:
	# Defer the replacement if this can be triggered from signals like body_entered
	call_deferred("_do_replace_with_human")

func _do_replace_with_human() -> void:
	var parent := get_parent()
	if parent == null:
		push_error("Cannot replace: zombie has no parent.")
		return
		
	var human_packed := load("res://Scenes/Human.tscn")
	if human_packed == null:
		push_error("Failed to load Human scene at res://Scenes/Human.tscn")
		return
		
	var human : Node = human_packed.instantiate()
	if human == null:
		push_error("Failed to instantiate Human scene.")
		return
		
	parent.add_child(human)
	
	# If both are Node2D/CharacterBody2D, copy global transform to be exact
	if human is Node2D and self is Node2D:
		human.global_transform = self.global_transform
	elif human.has_method("set_global_position") and self.has_method("get_global_position"):
		human.global_position = self.global_position
	else:
	# Fallback if types differ; you can customize this
	# For 3D use: human.global_transform = self.global_transform
		pass

	print("Spawned human at: ", human.global_position)
	print("I am at: ", self.global_position)
	# Optional: keep the same sibling order
	parent.move_child(human, get_index())
	# Now safely remove the zombie
	queue_free()
	print("I'm Cured!")
