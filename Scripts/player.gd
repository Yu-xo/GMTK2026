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
@export var DropRate: Timer

# Player Stats
var hp: int
var move_speed: int

# Dash
@export var DashSpeed := 450.0
var DashDuration: float
var DashCooldown: float

var can_dash := true
var is_dashing := false
var dash_direction := Vector2.ZERO

# Bombs
var drop_cooldown: float
var number_of_bombs: int

var can_drop := true


func _ready() -> void:
	DropRate.timeout.connect(_on_drop_timeout)
	_update_stats()


func _physics_process(delta: float) -> void:

	if is_dashing:
		velocity = dash_direction * DashSpeed
		move_and_slide()
		return

	_state_handler(delta)
	move_and_slide()


func _update_stats() -> void:

	hp = UpgardeEffects.max_hp
	move_speed = UpgardeEffects.max_speed

	DashCooldown = UpgardeEffects.dash_cooldown
	DashDuration = UpgardeEffects.dash_distance

	number_of_bombs = UpgardeEffects.bomb_count
	drop_cooldown = UpgardeEffects.bomb_drop_rate

	print("========== PLAYER STATS ==========")
	print("HP:", hp)
	print("Speed:", move_speed)
	print("Dash Cooldown:", DashCooldown)
	print("Dash Duration:", DashDuration)
	print("Bomb Count:", number_of_bombs)
	print("Bomb Cooldown:", drop_cooldown)
	print("Bomb Damage:", UpgardeEffects.max_dmg)
	print("Explosion Radius:", UpgardeEffects.explosion_radius)
	print("==================================")


func _state_handler(delta):

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
			pass


func _input(event):

	if event.is_action_pressed("dash") and can_dash:
		_start_dash()

	if event.is_action_pressed("attack") and can_drop:
		current_state = States.ATTACK


func _idle_state():

	dir = Input.get_vector("left","right","up","down")

	if dir != Vector2.ZERO:
		current_state = States.MOVE
	else:
		velocity = Vector2.ZERO


func _move_state():

	dir = Input.get_vector("left","right","up","down")

	velocity = dir * move_speed

	if dir == Vector2.ZERO:
		current_state = States.IDLE


func _start_dash():

	if !can_dash or is_dashing:
		return

	can_dash = false
	is_dashing = true

	dash_direction = Input.get_vector("left","right","up","down")

	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT

	await get_tree().create_timer(DashDuration).timeout

	is_dashing = false

	await get_tree().create_timer(DashCooldown).timeout

	can_dash = true


func _drop_bomb():

	can_drop = false

	for i in range(number_of_bombs):

		var bomb = BombNode.instantiate()

		bomb.global_position = Muzzle.global_position

		# Pass upgraded stats
		bomb.max_damage = UpgardeEffects.max_dmg
		bomb.explosion_radius = UpgardeEffects.explosion_radius

		get_tree().current_scene.add_child(bomb)

	DropRate.start(drop_cooldown)

	current_state = States.IDLE


func _on_drop_timeout():
	can_drop = true
