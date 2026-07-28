extends CharacterBody2D
class_name PlayerController
static var instance : PlayerController

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
var move_direction := Vector2.ZERO
var last_direction := Vector2.RIGHT

@onready var health: HealthController = $HealthController

@onready var sprite: Sprite2D = $Sprites/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var dash_sound_effect: AudioStreamPlayer2D = $DashSoundEffect

@export var BombNode: PackedScene
@export var DropRate: Timer
@export var UpgradeUI: Control

@onready var bomb_spawn_point: Marker2D = $BombSpawnPoint

var move_speed: int

@export var DashSpeed := 450.0

var DashDuration: float
var DashCooldown: float

var can_dash := true
var is_dashing := false

var drop_cooldown: float
var number_of_bombs: int

var can_drop := true

@export var KnockbackForce := 400.0
@export var HurtTime := 0.25
@export var InvincibleTime := 0.75

var can_take_damage := true
var knockback_velocity := Vector2.ZERO

signal on_updated_stats()
signal on_dropped_bomb()

# is called immediately when is spawned (before ready)
func _enter_tree() -> void:
	instance = self

# is called only after the scene is ready
func _ready() -> void:
	if DropRate:
		DropRate.timeout.connect(_on_drop_timeout)

	_update_stats()
	health.on_damaged.connect(on_damaged)
	health.on_death.connect(on_death)
	displayed_bomb = drop_cooldown
	set_flash(0)

func _physics_process(delta: float) -> void:
	move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if move_direction != Vector2.ZERO:
		last_direction = move_direction
		
	# Flip Sprite
	if sprite and move_direction.x != 0:
		sprite.flip_h = move_direction.x < 0
	
	if UpgradeUI:
		UpgradeUI.visible = false

	if is_dashing:
		velocity = last_direction * DashSpeed
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
		#health.current_health = UpgardeEffects.max_hp
		move_speed = UpgardeEffects.max_speed

		DashCooldown = UpgardeEffects.dash_cooldown
		DashDuration = UpgardeEffects.dash_distance

		number_of_bombs = UpgardeEffects.bomb_count
		drop_cooldown = UpgardeEffects.bomb_drop_rate

	displayed_bomb = drop_cooldown
	on_updated_stats.emit()
	
#region Player Management
func _state_handler(_delta):
	match current_state:
		States.IDLE, States.MOVE:
			_move_state()
		States.ATTACK:
			_drop_bomb()
		States.HURT:
			pass
		States.DEAD:
			return

func _input(event):
	if current_state == States.HURT or current_state == States.DEAD:
		return

	if event.is_action_pressed("dash") and can_dash:
		_start_dash()

	if event.is_action_pressed("attack") and can_drop:
		current_state = States.ATTACK
#endregion

#region
func _move_state() -> void:
	if move_direction == Vector2.ZERO:
		current_state = States.IDLE
		velocity = Vector2.ZERO

		if animation_player.current_animation != "idle":
			animation_player.play("idle")

		if audio_stream_player_2d.playing:
			audio_stream_player_2d.stop()
		return

	current_state = States.MOVE

	velocity = move_direction * move_speed

	if animation_player.current_animation != "walk":
		animation_player.play("walk")

	if !audio_stream_player_2d.playing:
		audio_stream_player_2d.play()

func _on_collect_area_area_entered(_area: Area2D) -> void:
	pass # Replace with function body
#endregion

#region Dashing
func _start_dash():
	if !can_dash or is_dashing:
		return

	if dash_sound_effect:
		dash_sound_effect.play()

	can_dash = false
	is_dashing = true

	if audio_stream_player_2d:
		audio_stream_player_2d.stop()

	await get_tree().create_timer(DashDuration).timeout
	is_dashing = false

	await get_tree().create_timer(DashCooldown).timeout
	can_dash = true
#endregion

#region Bombing
func _drop_bomb():
	if BombNode == null:
		current_state = States.IDLE
		return

	can_drop = false

	animation_player.play("bomb")

	displayed_bomb = 0.0
	var spawn_pos = bomb_spawn_point.global_position if bomb_spawn_point else global_position

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
	on_dropped_bomb.emit()
#endregion

#region Health Management
func _hurt_state(delta):
	velocity = knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1200 * delta)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if !body.is_in_group("enemy"):
		return

	if !can_take_damage:
		return

	can_take_damage = false
	health.take_damage(1)

func hit_player(amount: int, force: float, direction: Vector2):
	knockback_velocity = direction * force
	health.take_damage(amount)
	CameraManager.instance.apply_shake(18)

func on_damaged(_amount: int):
	if !can_take_damage:
		return

	can_take_damage = false
	current_state = States.HURT

	set_flash(1.0)

	var tween := create_tween()
	tween.tween_method(set_flash, 1.0, 0.0, HurtTime)
	
	await get_tree().create_timer(HurtTime).timeout

	if health.is_alive():
		current_state = States.IDLE

	await get_tree().create_timer(InvincibleTime).timeout
	can_take_damage = true

func set_flash(amount: float) -> void:
	if sprite.material:
		sprite.material.set_shader_parameter("flash_amount", amount)

func on_death():
	EnemySpawner.instance.show_game_over()
#endregion
