extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("all_players") and get_parent().holding_cure == true:
		get_parent().cure_quantity -= 1
		body.get_cured()
		print(get_parent().cure_quantity)
