extends Area2D

var has_damaged := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TrapCooldown.timeout.connect(trap_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(has_damaged)
	if not $TrapCooldown.is_stopped(): print($TrapCooldown.time_left)
	if $TrapCooldown.is_stopped() and has_overlapping_bodies():
		for bodies in get_overlapping_bodies():
			_on_body_entered(bodies)

func print_group(group_name: String) -> void:
	var members = get_tree().get_nodes_in_group(group_name)
	for node in members:
		print(node)  # prints the node reference




func _on_body_entered(body: Node2D) -> void:
	# Only damage if we haven't already damaged during this entry
	if not has_damaged and body.is_in_group("player"):
		body.take_damage(1)   # Calls the player’s damage method
		has_damaged = true
		$TrapCooldown.start()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_damaged = false

func trap_ready() -> void:
	has_damaged = false
