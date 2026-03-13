extends Area2D

#Preload Zombie
var ZombieScene := preload("res://Scenes/Zombie.tscn")

#State Variables
enum AI_Mode { IDLE, WANDER, FLEE }
var state: AI_Mode = AI_Mode.WANDER

var wander_direction := Vector2.ZERO
var wander_timer := 0.0
var wander_speed := 30.0

var idle_timer := 5.0

var flee_timer := 0.0

#Functions

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		AI_Mode.IDLE:
			pass
		AI_Mode.WANDER:
			wander_state(delta)
		AI_Mode.FLEE:
			pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("all_players"):
		call_deferred("convert_to_zombie")


func convert_to_zombie() -> void:
	var Zombie = ZombieScene.instantiate()
	Zombie.position = global_position
	get_parent().add_child(Zombie)
	queue_free()

func set_state(new_state: AI_Mode):
	state = new_state

func wander_state(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		wander_timer = randf_range(1.0, 3.0)
	velocity = wander_direction * wander_speed
	move_and_slide()
