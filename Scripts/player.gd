extends CharacterBody2D

enum States {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEAD
}

var current_state = States.IDLE
var displayed_hp: float
var displayed_bomb: float
var dir: Vector2

@onready var health_bar: TextureProgressBar = $HUD/HUDContainer/HealthBar
@onready var bomb_hud: TextureProgressBar = $HUD/HUDContainer/BombHud
@onready var number_of_bombs_label: Label = $HUD/HUDContainer/NumberOfBombs
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var dash_sound_effect: AudioStreamPlayer2D = $DashSoundEffect

@export var enemy_spawner: Node

@export var BombNode: PackedScene
@export var Muzzle: Marker2D
@export var DropRate: Timer

@export var camera: Camera2D

@export var UpgradeUI: Control

var hp: int
var move_speed: int

@export var DashSpeed := 450.0

var DashDuration: float
var DashCooldown: float

var can_dash := true
var is_dashing := false
var dash_direction := Vector2.ZERO

var drop_cooldown: float
var number_of_bombs: int

var can_drop := true

@export var KnockbackForce := 400.0
@export var HurtTime := 0.25
@export var InvincibleTime := 0.75

var can_take_damage := true
var knockback_velocity := Vector2.ZERO


func _ready() -> void:
	if DropRate:
		DropRate.timeout.connect(_on_drop_timeout)

	_update_stats()
	displayed_hp = hp
	displayed_bomb = drop_cooldown
	_update_hud(0.0)


func _physics_process(delta: float) -> void:
	if UpgradeUI:
		UpgradeUI.visible = false

	_update_hud(delta)

	if is_dashing:
		velocity = dash_direction * DashSpeed
		move_and_slide()
		return

	match current_state:
		States.HURT:
			_hurt_state(delta)

		States.DEAD:
			velocity = Vector2.ZERO

		_:
			_state_handler(delta)

	move_and_slide()


func _update_stats() -> void:
	if typeof(UpgardeEffects) != TYPE_NIL:
		hp = UpgardeEffects.max_hp
		move_speed = UpgardeEffects.max_speed

		DashCooldown = UpgardeEffects.dash_cooldown
		DashDuration = UpgardeEffects.dash_distance

		number_of_bombs = UpgardeEffects.bomb_count
		drop_cooldown = UpgardeEffects.bomb_drop_rate

	displayed_hp = hp
	displayed_bomb = drop_cooldown
	_update_hud(0.0)


func _update_hud(delta: float) -> void:
	if health_bar == null or bomb_hud == null or number_of_bombs_label == null:
		return

	health_bar.max_value = UpgardeEffects.max_hp if typeof(UpgardeEffects) != TYPE_NIL else hp
	displayed_hp = move_toward(displayed_hp, hp, 10.0 * delta)
	health_bar.value = displayed_hp

	number_of_bombs_label.text = str(number_of_bombs)

	bomb_hud.max_value = drop_cooldown

	var target := drop_cooldown
	if !can_drop and DropRate:
		target = drop_cooldown - DropRate.time_left

	displayed_bomb = move_toward(displayed_bomb, target, drop_cooldown * 6.0 * delta)
	bomb_hud.value = displayed_bomb


func _state_handler(_delta):
	match current_state:
		States.IDLE:
			_idle_state()

		States.MOVE:
			_move_state()

		States.ATTACK:
			_drop_bomb()

		States.HURT:
			pass

		States.DEAD:
			if enemy_spawner and enemy_spawner.has_method("show_game_over"):
				enemy_spawner.show_game_over()
			return


func _input(event):
	if current_state == States.HURT or current_state == States.DEAD:
		return

	if event.is_action_pressed("dash") and can_dash:
		_start_dash()

	if event.is_action_pressed("attack") and can_drop:
		current_state = States.ATTACK


func _move_direction() -> void:
	if animated_sprite_2d == null:
		return

	if dir.x < 0:
		animated_sprite_2d.flip_h = true
	elif dir.x > 0:
		animated_sprite_2d.flip_h = false


func _idle_state():
	dir = Input.get_vector("left", "right", "up", "down")

	if dir != Vector2.ZERO:
		current_state = States.MOVE
	else:
		velocity = Vector2.ZERO

		if audio_stream_player_2d and audio_stream_player_2d.playing:
			audio_stream_player_2d.stop()


func _move_state():
	dir = Input.get_vector("left", "right", "up", "down")

	_move_direction()

	velocity = dir * move_speed

	if audio_stream_player_2d and !audio_stream_player_2d.playing:
		audio_stream_player_2d.play()

	if dir == Vector2.ZERO:
		current_state = States.IDLE


func _hurt_state(delta):
	velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1200 * delta)


func _start_dash():
	if !can_dash or is_dashing:
		return

	if dash_sound_effect:
		dash_sound_effect.play()

	can_dash = false
	is_dashing = true

	if audio_stream_player_2d:
		audio_stream_player_2d.stop()

	dash_direction = Input.get_vector("left", "right", "up", "down")

	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT

	await get_tree().create_timer(DashDuration).timeout
	is_dashing = false

	await get_tree().create_timer(DashCooldown).timeout
	can_dash = true


func _drop_bomb():
	if BombNode == null:
		current_state = States.IDLE
		return

	can_drop = false

	displayed_bomb = 0.0
	if bomb_hud:
		bomb_hud.value = 0.0

	var spawn_pos = Muzzle.global_position if Muzzle else global_position

	for i in range(number_of_bombs):
		var bomb = BombNode.instantiate()
		bomb.global_position = spawn_pos

		if typeof(UpgardeEffects) != TYPE_NIL:
			bomb.max_damage = UpgardeEffects.max_dmg
			bomb.explosion_radius = UpgardeEffects.explosion_radius

		get_tree().current_scene.add_child(bomb)

	if DropRate:
		DropRate.start(drop_cooldown)

	current_state = States.IDLE


func _on_drop_timeout():
	can_drop = true
	_update_hud(0.0)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if audio_stream_player_2d:
		audio_stream_player_2d.stop()

	if !body.is_in_group("enemy"):
		return

	if !can_take_damage:
		return

	can_take_damage = false
	hp -= 1

	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(18.0)

	_update_hud(0.0)

	if hp <= 0:
		current_state = States.DEAD
		if enemy_spawner and enemy_spawner.has_method("show_game_over"):
			enemy_spawner.show_game_over()
		return

	current_state = States.HURT

	var knockback_dir = (global_position - body.global_position).normalized()
	knockback_velocity = knockback_dir * KnockbackForce

	await get_tree().create_timer(HurtTime).timeout

	if current_state != States.DEAD:
		current_state = States.IDLE

	await get_tree().create_timer(InvincibleTime).timeout
	can_take_damage = true


func _hit_player(damage_amount: int, force: float, direction: Vector2) -> void:
	if audio_stream_player_2d:
		audio_stream_player_2d.stop()

	if !can_take_damage:
		return

	can_take_damage = false
	hp -= damage_amount

	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(25.0)

	_update_hud(0.0)

	if hp <= 0:
		current_state = States.DEAD
		if enemy_spawner and enemy_spawner.has_method("show_game_over"):
			enemy_spawner.show_game_over()
		return

	current_state = States.HURT
	knockback_velocity = direction * force

	await get_tree().create_timer(HurtTime).timeout

	if current_state != States.DEAD:
		current_state = States.IDLE

	await get_tree().create_timer(InvincibleTime).timeout
	can_take_damage = true
