extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/VBoxMain.visible = true
	$CanvasLayer/VBoxSettings.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_settings_button_pressed() -> void:
	$CanvasLayer/VBoxMain.visible = false
	$CanvasLayer/VBoxSettings.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(640,360))
		1:
			DisplayServer.window_set_size(Vector2i(1280,720))
		2:
			DisplayServer.window_set_size(Vector2i(1920,1080))
	

func _on_back_button_pressed() -> void:
	$CanvasLayer/VBoxMain.visible = true
	$CanvasLayer/VBoxSettings.visible = false


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Score.master_volume = $CanvasLayer/VBoxSettings/MasterVolume.value
	print(Score.master_volume)
