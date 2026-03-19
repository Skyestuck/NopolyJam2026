extends Area2D

var parent_ref
enum AI_Mode { IDLE, WANDER, FLEE, CHASE, RESTOCK, RECRUIT}
var parent_state: AI_Mode = AI_Mode.IDLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_ref = get_parent() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if parent_ref:
		parent_state = parent_ref.state


#func _on_body_entered(body: Node2D) -> void:
	#match parent_state:
		#AI_Mode.RECRUIT:
			#if body.is_in_group("non_military_human"):
				#body.get_recruited()
				#print("RecruitAttempt")
		#_:
			#pass
