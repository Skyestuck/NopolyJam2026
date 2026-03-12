extends Area2D

var ZombieScene := preload("res://Scenes/Zombie.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("My postion is: ", position.x, position.y)
	#pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("all_players"):
		queue_free()
		var Zombie = ZombieScene.instantiate()
		Zombie.position = Vector2(position.x,position.y)
		get_parent().add_child(Zombie) # Replace with function body.
