extends Control

var enemy_spawner: EnemySpawner
var _panel_start_position: Vector2

@export_group("End Screen")
@onready var panel: TextureRect = $Panel
@onready var background: ColorRect = $Background
@onready var end_game_values: RichTextLabel = $Panel/EndGameValues
@onready var try_again_button: TextureButton = $Panel/TryAgainButton

func _ready() -> void:
	visible = false

	_panel_start_position = panel.position

	enemy_spawner = EnemySpawner.instance
	enemy_spawner.on_game_ended.connect(show_game_over)

func show_game_over() -> void:
	await get_tree().create_timer(0.2).timeout

	var wave_reached := enemy_spawner.round_num + 1
	end_game_values.bbcode_enabled = true
	end_game_values.text = "[center][b][font_size=24]WAVES SURVIVED: %d[/font_size][/b][/center]" % wave_reached

	visible = true

	# Reset
	panel.position = _panel_start_position + Vector2(0, -700)
	panel.modulate.a = 1.0

	background.modulate.a = 0.0
	end_game_values.modulate.a = 0.0

	try_again_button.modulate.a = 0.0
	try_again_button.disabled = true

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	# Fade background while panel falls in
	tween.parallel().tween_property(background, "modulate:a", 0.75, 0.35)

	tween.parallel().tween_property(
		panel,
		"position",
		_panel_start_position,
		0.7
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# Wait for the panel animation
	tween.tween_interval(0.15)

	# Fade in the text
	tween.parallel().tween_property(end_game_values, "modulate:a", 1.0, 0.25)

	# Then the button
	tween.tween_interval(0.1)
	tween.tween_property(try_again_button, "modulate:a", 1.0, 0.25)

	await tween.finished

	try_again_button.disabled = false

func _on_try_again_button_pressed() -> void:
	enemy_spawner._on_try_again_pressed()
