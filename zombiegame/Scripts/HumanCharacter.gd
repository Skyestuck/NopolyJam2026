extends CharacterBody2D

#Preload Zombie
var ZombieScene := preload("res://Scenes/Zombie.tscn")



#State Variables
enum AI_Mode { IDLE, WANDER, FLEE }
var state: AI_Mode = AI_Mode.WANDER

var wander_direction := Vector2.ZERO
const wander_duration_short := 1.0
const wander_duration_long := 3.0
var wander_timer := 0.0
var wander_speed := 10.0

const idle_duration_short := 1.0
const idle_duration_long := 2.0
var idle_timer := 0.0

var alertness := 0.0
var flee_timer := 0.0

func _physics_process(delta: float) -> void:
	match state:
		AI_Mode.IDLE:
			idle_state(delta)
		AI_Mode.WANDER:
			wander_state(delta)
		AI_Mode.FLEE:
			flee_state(delta)
	move_and_slide()

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
		idle_timer = randf_range(idle_duration_short, idle_duration_long)
		print("Switching to IDLE!")
		set_state(AI_Mode.IDLE)
		return
	velocity = wander_direction * wander_speed
	move_and_slide()

func idle_state(delta):
	idle_timer -= delta
	velocity = Vector2.ZERO
	move_and_slide()
	if idle_timer <= 0:
		wander_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		wander_timer = randf_range(wander_duration_short, wander_duration_long)
		print("Switching to WANDER!")
		set_state(AI_Mode.WANDER)

func flee_state(delta):
	pass
