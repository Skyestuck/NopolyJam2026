extends CharacterBody2D


#State Variables
enum AI_Mode { IDLE, WANDER, FLEE, CHASE, RESTOCK, RECRUIT}
var state: AI_Mode = AI_Mode.WANDER
var vaccindated := false
@export var holding_cure := true
var cure_top_up := 5
var cure_quantity := 5

var wander_direction := Vector2.ZERO
@export var wander_duration_short := 1.0
@export var wander_duration_long := 3.0
var wander_timer := 0.0
var wander_speed := 30.0

@export var idle_duration_short := 0.5
@export var idle_duration_long := 1.5
var idle_timer := 0.0

var misc_speed := 50.0

var direction : Vector2 = Vector2.ZERO
var alertness := 0.0
@export var alertness_trigger := 2.2
var alertness_max = 5.0
var flee_timer := 0.0
var flee_speed := 80.0
var sprite_facing := "none"

var chase_speed := 80.0

var small_vision = 0.6
var regular_vision = 1.0

var recruit_timer = 0.0
var recruit_trigger = 60.0

func _ready():
	add_to_group("all_humans")
	add_to_group("all_military")
	$Alert.visible = false
	$Cure.visible = false
	$Suspicion.visible = false

func _physics_process(delta: float) -> void:
	recruit_timer += delta
	recruit_timer = min(recruit_timer, recruit_trigger)
	print(recruit_timer)

	if cure_quantity >= 1:
		holding_cure = true
	else:
		holding_cure = false
	
	match state:
		AI_Mode.IDLE:
			idle_state(delta)
		AI_Mode.WANDER:
			wander_state(delta)
		AI_Mode.FLEE:
			flee_state(delta)
		AI_Mode.CHASE:
			chase_state(delta)
		AI_Mode.RESTOCK:
			restock_state(delta)
		AI_Mode.RECRUIT:
			recruit_state(delta)
	
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
					$Cure.visible = false
					#print("Setting frame for:", sprite_facing)
				"up":
					$Sprite2D.frame = 3
					$DetectionLOS.rotation = 180
					$Alert.visible = false
					$Cure.visible = false
					#print("Setting frame for:", sprite_facing)
				"left":
					$Sprite2D.frame = 1
					$DetectionLOS.rotation = 90
					$Alert.visible = false
					$Cure.visible = false
					#print("Setting frame for:", sprite_facing)
				"right":
					$Sprite2D.frame = 2
					$DetectionLOS.rotation = -90
					$Alert.visible = false
					$Cure.visible = false
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

#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("all_players") and holding_cure == true:
		#cure_quantity -= 1asw
		#body.get_cured()
		#print("TAKE THIS CURE")

func convert_to_zombie() -> void:
	pass

func get_terror(delta) -> void:
	#Military Chases the zombie once they're aware of it. They will chase if they have cures
	#if they don't have cures, they will try to return to a cure zone to restock
	if alertness < alertness_max:
		alertness += delta*2
		$Suspicion.visible = true
	if alertness >= alertness_trigger and holding_cure == true:
		set_state(AI_Mode.CHASE)
		$Suspicion.visible = false
		$Cure.visible = true
	elif alertness >= alertness_trigger and holding_cure == false:
		set_state(AI_Mode.FLEE)
		$Suspicion.visible = false
		$Alert.visible = true


func set_state(new_state: AI_Mode):
	state = new_state

func wander_state(delta):
	#Check for higher priority tasks
	if holding_cure == false:
		set_state(AI_Mode.RESTOCK)
	elif recruit_timer >= recruit_trigger:
		set_state(AI_Mode.RECRUIT)
	#nothing better to do... then Idle
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
	#Check for higher priority tasks
	if holding_cure == false:
		set_state(AI_Mode.RESTOCK)
	elif recruit_timer >= recruit_trigger:
		set_state(AI_Mode.RECRUIT)
	#nothing better to do... then Wander
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
		idle_timer = randf_range(idle_duration_short, idle_duration_long)
		#print("Switching to IDLE!")
		set_state(AI_Mode.IDLE)

func get_nearest_zombie(zombies: Array, me: Vector2) -> Vector2:
	var nearest:= Vector2.ZERO
	var nearest_dist := INF
	for zombie in zombies:
		var pos: Vector2 = zombie.global_position
		var d = me.distance_to(pos)
		if d < nearest_dist:
			nearest_dist = d
			nearest = pos
	return nearest


func chase_state(delta):
	if $DetectionArea.has_overlapping_bodies():
		direction = (get_nearest_zombie($DetectionArea.get_overlapping_bodies(), global_position) - global_position).normalized()
		velocity = direction * chase_speed
	else:
		set_state(AI_Mode.WANDER)

func restock_state(delta):
	if not $DetectionArea.has_overlapping_bodies() and holding_cure == false:
		#get nearest cure zone, actually
		direction = (get_nearest_zombie(get_tree().get_nodes_in_group("cure_zone"), global_position) - global_position).normalized()
		velocity = direction * misc_speed
	else:
		set_state(AI_Mode.WANDER)

func recruit_state(delta):
	if not $DetectionArea.has_overlapping_bodies() and recruit_timer >= recruit_trigger:
		#get nearest human, actually
		direction = (get_nearest_zombie(get_tree().get_nodes_in_group("non_military_humans"), global_position) - global_position).normalized()
		velocity = direction * misc_speed
		if $RecruitingArea.has_overlapping_bodies():
			var recruits = $RecruitingArea.get_overlapping_bodies()
			for r in recruits:
				if not r.is_in_group("all_military"):
					r.get_recruited()
					recruit_timer = 0
					break
	else:
		set_state(AI_Mode.WANDER)
