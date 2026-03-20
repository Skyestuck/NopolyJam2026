extends Label

var flashing: bool = false
var flash_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_color_override("font_color", Color.WHITE)
	set_flashing(Score.zombie_count == 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Zombies: " + str(int(Score.zombie_count))
	var should_flash: bool = (Score.zombie_count == 1)
	if should_flash != flashing:
		set_flashing(should_flash)

func set_flashing(enable: bool) -> void:
	flashing = enable
	
	if flash_tween:
		flash_tween.kill()
		flash_tween = null
	
	if enable:
		add_theme_color_override("font_color", Color.WHITE)
		
		flash_tween = create_tween()
		flash_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()
		
		flash_tween.tween_property(self, "theme_override_colors/font_color", Color(1, 0, 0, 1), 0.6).from(Color(1, 1, 1, 1))
		
		flash_tween.tween_property(self, "theme_override_colors/font_color", Color(1, 1, 1, 1), 0.6)
		
	else:
		add_theme_color_override("font_color", Color.WHITE)
