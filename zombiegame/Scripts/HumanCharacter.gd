extends CharacterBody2D

#Preload Zombie
var ZombieScene := preload("res://Scenes/Zombie.tscn")
var MilitaryScene := preload("res://Scenes/Military.tscn")

#State Variables
enum AI_Mode { IDLE, WANDER, FLEE }
var state: AI_Mode = AI_Mode.WANDER
var vaccindated := false
var holding_cure := false


var wander_direction := Vector2.ZERO
@export var wander_duration_short := 1.0
@export var wander_duration_long := 3.0
var wander_timer := 0.0
var wander_speed := 20.0

@export var idle_duration_short := 1.0
@export var idle_duration_long := 2.0
var idle_timer := 0.0

var direction : Vector2 = Vector2.ZERO
var alertness := 0.0
@export var alertness_trigger := 2.2
var alertness_max = 10.0
var flee_timer := 0.0
var flee_speed := 80.0
var sprite_facing := "none"

func _ready():
	add_to_group("all_humans")
	add_to_group("non_military_humans")
	$Alert.visible = false
	$Suspicion.visible = false

func _physics_process(delta: float) -> void:
	match state:
		AI_Mode.IDLE:
			idle_state(delta)
		AI_Mode.WANDER:
			wander_state(delta)
		AI_Mode.FLEE:
			flee_state(delta)
	
	sprite_facing = get_direction(direction)
	
	match state:
		AI_Mode.FLEE:
			match sprite_facing:
				"none", "down":
					$Sprite2D.frame = 4
					$DetectionLOS.rotation = 0
					#print("Setting frame for:", sprite_facing, " Scream")
				"up":
					$Sprite2D.frame = 7
					$DetectionLOS.rotation = 180
					#print("Setting frame for:", sprite_facing, " Scream")
				"left":
					$Sprite2D.frame = 5
					$DetectionLOS.rotation = 90
					#print("Setting frame for:", sprite_facing, " Scream")
				"right":
					$Sprite2D.frame = 6
					$DetectionLOS.rotation = -90
					#print("Setting frame for:", sprite_facing, " Scream")
		_:
			match sprite_facing:
				"none", "down":
					$Sprite2D.frame = 0
					$DetectionLOS.rotation = 0
					$Alert.visible = false
					#print("Setting frame for:", sprite_facing)
				"up":
					$Sprite2D.frame = 3
					$DetectionLOS.rotation = 180
					$Alert.visible = false
					#print("Setting frame for:", sprite_facing)
				"left":
					$Sprite2D.frame = 1
					$DetectionLOS.rotation = 90
					$Alert.visible = false
					#print("Setting frame for:", sprite_facing)
				"right":
					$Sprite2D.frame = 2
					$DetectionLOS.rotation = -90
					$Alert.visible = false
					#print("Setting frame for:", sprite_facing)
	
	move_and_slide()
	if not alertness <= 0.0:
		alertness -= delta
	else:
		$Suspicion.visible = false

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

func convert_to_zombie() -> void:
	var parent := get_parent()
	if parent == null:
		return
	
	var Zombie: Node =  ZombieScene.instantiate()
	parent.add_child(Zombie)
	if Zombie is Node2D:
		Zombie.global_transform = global_transform
		Score.zombie_count += 1
		Score.score += 10
	queue_free()

func get_terror(delta) -> void:
	if alertness < alertness_max:
		alertness += delta*2
		$Suspicion.visible = true
	if alertness >= alertness_trigger:
		set_state(AI_Mode.FLEE)
		$Suspicion.visible = false
		$Alert.visible = true


func set_state(new_state: AI_Mode):
	state = new_state

func wander_state(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		idle_timer = randf_range(idle_duration_short, idle_duration_long)
		#print("Switching to IDLE!")
		wander_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		direction = wander_direction
		set_state(AI_Mode.IDLE)
		return
	velocity = direction * wander_speed

func idle_state(delta):
	idle_timer -= delta
	velocity = Vector2.ZERO
	if idle_timer <= 0:
		wander_timer = randf_range(wander_duration_short, wander_duration_long)
		#print("Switching to WANDER!")
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
		#print($DetectionArea.get_overlapping_bodies())
	#print (direction)
	velocity = direction * flee_speed
	if alertness < alertness_trigger:
		$Suspicion.visible = false 
		idle_timer = randf_range(idle_duration_short, idle_duration_long)
		#print("Switching to IDLE!")
		set_state(AI_Mode.IDLE)

func get_recruited() -> void:
	var parent := get_parent()
	if parent == null:
		return
	
	var Military: Node =  MilitaryScene.instantiate()
	parent.add_child(Military)
	if Military is Node2D:
		Military.global_transform = global_transform
	queue_free()
