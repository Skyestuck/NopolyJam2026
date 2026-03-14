extends CharacterBody2D

#Preload Zombie
var ZombieScene := preload("res://Scenes/Zombie.tscn")

#State Variables
enum AI_Mode { IDLE, WANDER, FLEE }
var state: AI_Mode = AI_Mode.WANDER

var wander_direction := Vector2.ZERO
@export var wander_duration_short := 1.0
@export var wander_duration_long := 3.0
var wander_timer := 0.0
var wander_speed := 10.0

@export var idle_duration_short := 1.0
@export var idle_duration_long := 2.0
var idle_timer := 0.0

var direction : Vector2 = Vector2.ZERO
var alertness := 0.0
const alertness_trigger := 1.0
var flee_timer := 0.0
var flee_speed := 20.0

func _ready():
	add_to_group("all_humans")

func _physics_process(delta: float) -> void:
	match state:
		AI_Mode.IDLE:
			idle_state(delta)
		AI_Mode.WANDER:
			wander_state(delta)
		AI_Mode.FLEE:
			flee_state(delta)
	if not alertness <= 0.0:
		alertness -= delta
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("all_players"):
		call_deferred("convert_to_zombie")

func convert_to_zombie() -> void:
	var Zombie = ZombieScene.instantiate()
	Zombie.position = global_position
	get_parent().add_child(Zombie)
	queue_free()

func get_terror(delta) -> void:
	alertness += delta*2
	if alertness >= alertness_trigger:
		set_state(AI_Mode.FLEE)

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

func get_point_zombies_near(points: Array) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	var sum := Vector2.ZERO
	var count := 0
	
	for p in points:
		if is_instance_valid(p):
			sum += p.global_position
			count += 1
	if count == 0: return Vector2.ZERO
	else: return (sum / float(count))


func flee_state(delta):
	if not $DetectionArea.get_overlapping_bodies().is_empty():
		direction = (global_position - get_point_zombies_near($DetectionArea.get_overlapping_bodies())).normalized()
	print (direction)
	velocity = direction * flee_speed
	move_and_slide()
	if alertness < alertness_trigger:
		idle_timer = randf_range(idle_duration_short, idle_duration_long)
		print("Switching to IDLE!")
		set_state(AI_Mode.IDLE)
