extends Node2D

var enemy_scene: Array[PackedScene] = [
	preload("uid://dxf7nvtn0td7k"),
	preload("uid://b2dk223mp3erv"),
	preload("uid://udbwv1trouo1")
]

@export_group("End Screen")
@export var panel: Control
@export var end_view: Control
@export var color_rect: ColorRect
@export var ValueContiner: TextureRect
@export var try_again: TextureButton
@export var rich_text_label: RichTextLabel
@export var end_game_values: RichTextLabel

enum EnemyType {MELEE, RANGE, TANK}
enum SpawnPattern {ASCENDING, MIX, BOTH}

@export_group("UI & Nodes")
@export var wavename: RichTextLabel
@export var tutorial_label: RichTextLabel
@export var TelegraphNode: PackedScene
@export var telegraph_time := 0.8
@export var spawn_points: Array[Marker2D]
@export var UpgradeUI: Control

var is_spawning: bool = false

var melee_wave: Array[int] = [
	3, 4, 5,
	5, 6, 7, 8,
	8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20,
	22, 24, 26, 28, 30,
	32, 34, 36, 38, 40
]

var range_wave: Array[int] = [
	2, 1, 1,

	2, 2, 3, 3,

	4, 4, 5, 5, 6, 6, 7, 7,

	8, 8, 9, 10, 11,
	12, 13, 14, 15, 16,
	17, 18, 19, 20, 22
]

var tank_wave: Array[int] = [
	0, 0, 0, 0, 0, 0, 0,

	1, 1, 2, 2, 3, 3, 4, 4,

	5, 5, 6, 6, 7,
	8, 9, 10, 11, 12,
	13, 14, 15, 16, 18
]

@export var spawn_time: Array[float] = [2.0, 6.0, 10.0]

var spawned_enemies: Array[CharacterBody2D]
var round_num: int = 0
var in_tutorial: bool = false

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


func _ready():
	if end_view:
		end_view.visible = false

	if try_again:
		try_again.pressed.connect(_on_try_again_pressed)

	if animation_player:
		animation_player.play("Start")
		await animation_player.animation_finished

	var label = _get_display_label()
	if label:
		label.bbcode_enabled = true
		label.pivot_offset = label.size / 2.0

	_start_game_sequence()


func _get_display_label() -> RichTextLabel:
	return tutorial_label if tutorial_label else wavename


func _start_game_sequence() -> void:
	in_tutorial = true

	await _display_tutorial_step("[center][b][font_size=28][color=gold]MOVE[/color]\nPress [color=cyan]W, A, S, D[/color] to Move[/font_size][/b][/center]")
	await _wait_for_input_action(["up", "down", "left", "right"])

	await _display_tutorial_step("[center][b][font_size=28][color=gold]ATTACK[/color]\nPress [color=crimson]Left Click[/color] to Drop Bomb[/font_size][/b][/center]")
	await _wait_for_input_action(["attack", "plant_bomb"])

	await _display_tutorial_step("[center][b][font_size=28][color=gold]DASH[/color]\nPress [color=springgreen]Right Click[/color] to Dash[/font_size][/b][/center]")
	await _wait_for_input_action(["dash"])

	await _display_tutorial_step("[center][b][font_size=36][wave amp=50.0 freq=5.0 connected=1][color=gold]GOOD LUCK![/color][/wave][/font_size][/b][/center]", 1.5)

	in_tutorial = false
	_start_next_round(round_num)


func _display_tutorial_step(text_content: String, display_time: float = 0.0) -> void:
	var label = _get_display_label()
	if label == null:
		return

	label.text = text_content
	label.modulate.a = 0.0
	label.scale = Vector2(0.6, 0.6)

	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished

	if display_time > 0.0:
		await get_tree().create_timer(display_time).timeout
		var fade_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fade_tween.tween_property(label, "modulate:a", 0.0, 0.4)
		await fade_tween.finished


func _wait_for_input_action(actions: Array[String]) -> void:
	while true:
		await get_tree().process_frame

		for action in actions:
			if Input.is_action_just_pressed(action):
				return


func _spawn_enemy(round_param: int) -> void:
	if is_spawning:
		return
	is_spawning = true

	if round_param >= melee_wave.size():
		is_spawning = false
		return

	if round_param == 0:
		for i in range(2):
			await get_tree().create_timer(spawn_time[0]).timeout
			await _spawn_with_telegraph(enemy_scene[EnemyType.MELEE])
		is_spawning = false
		return

	var m_count = melee_wave[round_param]
	for i in range(m_count):
		await get_tree().create_timer(spawn_time[0]).timeout
		await _spawn_with_telegraph(enemy_scene[EnemyType.MELEE])

	var r_count = range_wave[round_param]
	for i in range(r_count):
		await get_tree().create_timer(spawn_time[1]).timeout
		await _spawn_with_telegraph(enemy_scene[EnemyType.RANGE])

	var t_count = tank_wave[round_param]
	for i in range(t_count):
		await get_tree().create_timer(spawn_time[2]).timeout
		await _spawn_with_telegraph(enemy_scene[EnemyType.TANK])

	is_spawning = false


func _enemy_killed(enemy: CharacterBody2D) -> void:
	spawned_enemies.erase(enemy)

	if !spawned_enemies.is_empty():
		return

	round_num += 1

	get_tree().paused = true

	if UpgradeUI:
		UpgradeUI.open_upgrade_screen()


func _start_next_round(round_param: int) -> void:
	if round_param >= melee_wave.size():
		return

	_update_wave_label(round_param + 1)
	await get_tree().create_timer(2.0).timeout
	_spawn_enemy(round_param)


func _update_wave_label(wave_number: int) -> void:
	if wavename == null:
		return

	wavename.text = "[center][b][font_size=32][color=gold]WAVE[/color] [wave amp=50.0 freq=5.0 connected=1][color=crimson]%d[/color][/wave][/font_size][/b][/center]" % wave_number

	wavename.modulate.a = 0.0
	wavename.scale = Vector2(0.5, 0.5)

	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.parallel().tween_property(wavename, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(wavename, "scale", Vector2(1.2, 1.2), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(wavename, "scale", Vector2(1.0, 1.0), 0.2)

	tween.tween_interval(1.5)
	tween.tween_property(wavename, "modulate:a", 0.0, 0.6)


func _spawn_position() -> Vector2:
	if spawn_points.is_empty():
		push_error("No spawn points assigned in spawn_points Array!")
		return Vector2.ZERO

	var marker: Marker2D = spawn_points.pick_random()
	return marker.global_position


func start_next_wave() -> void:
	get_tree().paused = false
	_start_next_round(round_num)


func _spawn_with_telegraph(scene: PackedScene) -> void:
	if scene == null:
		return

	var spawn_pos := _spawn_position()

	var telegraph: Node2D = TelegraphNode.instantiate()
	telegraph.global_position = spawn_pos
	get_parent().add_child(telegraph)

	var sprite: AnimatedSprite2D = telegraph.get_node("AnimatedSprite2D")
	sprite.play("idle")

	await sprite.animation_finished

	telegraph.queue_free()

	var enemy: CharacterBody2D = scene.instantiate()
	enemy.global_position = spawn_pos

	spawned_enemies.append(enemy)
	get_parent().add_child(enemy)


func show_game_over() -> void:
	get_tree().paused = true

	if end_game_values:
		end_game_values.bbcode_enabled = true
		var wave_reached = round_num + 1
		end_game_values.text = "[center][b][font_size=24]WAVES SURVIVED: [color=gold]%d[/color][/font_size][/b][/center]" % wave_reached

	if end_view:
		end_view.visible = true

	if panel:
		panel.position = Vector2(0, -800)

	if ValueContiner: ValueContiner.modulate.a = 0.0
	if end_game_values: end_game_values.modulate.a = 0.0
	if try_again:
		try_again.modulate.a = 0.0
		try_again.disabled = true

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if panel:
		tween.tween_property(
			panel,
			"position:y",
			0.0,
			0.6
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.15)

	if ValueContiner: tween.parallel().tween_property(ValueContiner, "modulate:a", 1.0, 0.25)
	if end_game_values: tween.parallel().tween_property(end_game_values, "modulate:a", 1.0, 0.25)
	if try_again: tween.parallel().tween_property(try_again, "modulate:a", 1.0, 0.25)

	await tween.finished

	if try_again:
		try_again.disabled = false


func _on_try_again_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
