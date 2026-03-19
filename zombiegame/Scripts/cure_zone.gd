extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("cure_zone") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_overlapping_bodies().size() > 0:
		for body in get_overlapping_bodies():
			if body.is_in_group("all_military") and body.cure_quantity != body.cure_top_up:
				body.cure_quantity = body.cure_top_up
				#print("Restock!")
