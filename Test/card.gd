extends Control

@onready var back_side: TextureRect = $BackSide
@onready var front_side: TextureRect = $FrontSide
@onready var label: Label = $FrontSide/Label

var start_pos: Vector2
var center_pos: Vector2


func _ready() -> void:
	await get_tree().process_frame

	start_pos = Vector2(
		position.y,
		-size.y - 100
	)

	center_pos = Vector2(
		position.y,
		(get_viewport_rect().size.y - size.y) / 2.0
	)

	position = start_pos

	back_side.visible = true
	front_side.visible = false

	back_side.scale = Vector2.ONE
	front_side.scale = Vector2.ONE

	back_side.pivot_offset = back_side.size / 2.0
	front_side.pivot_offset = front_side.size / 2.0

	show_card()
func show_card() -> void:

	position = start_pos

	back_side.visible = true
	front_side.visible = false

	back_side.scale = Vector2.ONE
	front_side.scale = Vector2.ONE

	# Slide in
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", center_pos, 0.45)

	await tween.finished

	await _flip_to_front()


func _flip_to_front() -> void:

	# Fold back side
	var tween = create_tween()
	tween.tween_property(back_side, "scale", Vector2(1.0, 0.0), 0.12)

	await tween.finished

	back_side.visible = false

	# Show folded front
	front_side.visible = true
	front_side.scale = Vector2(1.0, 0.0)

	# Unfold front
	var tween2 = create_tween()
	tween2.tween_property(front_side, "scale", Vector2.ONE, 0.12)

	await tween2.finished


func hide_card() -> void:

	# Fold front
	var tween = create_tween()
	tween.tween_property(front_side, "scale", Vector2(1.0, 0.0), 0.12)

	await tween.finished

	front_side.visible = false

	# Show folded back
	back_side.visible = true
	back_side.scale = Vector2(1.0, 0.0)

	# Unfold back
	var tween2 = create_tween()
	tween2.tween_property(back_side, "scale", Vector2.ONE, 0.12)

	await tween2.finished

	# Slide out
	var tween3 = create_tween()
	tween3.set_trans(Tween.TRANS_BACK)
	tween3.set_ease(Tween.EASE_IN)
	tween3.tween_property(self, "position", start_pos, 0.45)

	await tween3.finished
