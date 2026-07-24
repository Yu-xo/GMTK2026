extends CharacterBody2D

enum States {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEAD
}

var current_state = States.IDLE

var dir: Vector2

@export var BombNode: PackedScene
@export var Muzzle: Marker2D

@export var CircleColor := Color(1, 1, 1, 0.12)

# Dash Settings
@export var DashSpeed := 450.0
@export var DashDuration := 0.18
@export var DashCooldown := 0.6

var can_dash := true
var is_dashing := false
var dash_direction := Vector2.ZERO

var aiming := false
var throw_target: Vector2


func _ready() -> void:
	throw_target = global_position


func _physics_process(delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return

	if aiming:
		_update_throw_target()

	_state_handler(delta)
	move_and_slide()

	if aiming:
		queue_redraw()


func _state_handler(delta):
	match current_state:
		States.IDLE:
			_idle_state()

		States.MOVE:
			_movemovet_state()

		States.ATTACK:
			pass

		States.HURT:
			pass

		States.DEAD:
			pass


func _input(event):
	# Dash
	if event.is_action_pressed("dash"):
		if StatEffects.unlock_dash:
			_start_dash()

	# Throw Bomb
	if event.is_action_pressed("attack"):
		aiming = true
		current_state = States.ATTACK
		queue_redraw()

	elif event.is_action_released("attack"):

		if aiming:
			aiming = false

			var bomb = BombNode.instantiate()
			bomb.global_position = Muzzle.global_position
			bomb.target_pos = throw_target

			get_parent().add_child(bomb)

			current_state = States.IDLE
			queue_redraw()


func _idle_state():
	if aiming:
		velocity = Vector2.ZERO
		return

	dir = Input.get_vector("left", "right", "up", "down")

	if dir != Vector2.ZERO:
		current_state = States.MOVE
	else:
		velocity = Vector2.ZERO


func _movemovet_state():
	if aiming:
		velocity = Vector2.ZERO
		return

	dir = Input.get_vector("left", "right", "up", "down")

	velocity = dir * StatEffects.speed

	if dir == Vector2.ZERO:
		current_state = States.IDLE


func _start_dash():

	if !can_dash or is_dashing:
		return

	can_dash = false
	is_dashing = true

	dash_direction = Input.get_vector("left", "right", "up", "down")

	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT

	velocity = dash_direction.normalized() * DashSpeed

	await get_tree().create_timer(DashDuration).timeout

	velocity = Vector2.ZERO
	is_dashing = false

	await get_tree().create_timer(DashCooldown).timeout

	can_dash = true


func _update_throw_target():
	var mouse = get_global_mouse_position()

	var offset = mouse - global_position

	if offset.length() > StatEffects.throw_range:
		offset = offset.normalized() * StatEffects.throw_range

	throw_target = global_position + offset


func _draw():
	if !aiming:
		return

	draw_circle(
		Vector2.ZERO,
		StatEffects.throw_range,
		CircleColor
	)

	draw_arc(
		Vector2.ZERO,
		StatEffects.throw_range,
		0,
		TAU,
		72,
		Color.WHITE,
		2.0
	)

	draw_circle(
		to_local(throw_target),
		8,
		Color.RED
	)
