extends Node

func _display_number(value: int, display_pos: Vector2):
	var number = Label.new()
	number.global_position = display_pos
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var colour = Color.WHITE
	if value == 0:
		colour = Color(1.0, 1.0, 1.0, 0.0)
	
	number.label_settings.font_color = colour
	number.label_settings.font_size = 20
	number.label_settings.outline_color = Color.BLACK
	number.label_settings.outline_size = 1
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 25, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN).set_delay(0.3)
	
	await tween.finished
	number.queue_free()
