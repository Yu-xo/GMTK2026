extends Control
class_name GameHud

var player : PlayerController

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var bomb_hud: TextureProgressBar = $BombHud
@onready var bomb_count_label: Label = $BombHud/BombCountLabel

@export var health_bar_speed := 10.0

@export var health_shake_distance := 8.0
@export var health_shake_duration := 0.12

var _health_bar_start_pos: Vector2
var _health_shake_tween: Tween

func _ready() -> void:
	player = PlayerController.instance
	player.health.on_health_changed.connect(_health_changed)
	player.on_dropped_bomb.connect(update_hud)
	
	_health_bar_start_pos = health_bar.position
	
	update_hud()
	
#region health
func _health_changed(_amount: int):
	if _health_shake_tween:
		_health_shake_tween.kill()

	health_bar.position = _health_bar_start_pos

	_health_shake_tween = create_tween()
	_health_shake_tween.set_trans(Tween.TRANS_SINE)

	_health_shake_tween.tween_property(
		health_bar,
		"position",
		_health_bar_start_pos + Vector2(-health_shake_distance, 0),
		health_shake_duration * 0.25
	)

	_health_shake_tween.tween_property(
		health_bar,
		"position",
		_health_bar_start_pos + Vector2(health_shake_distance, 0),
		health_shake_duration * 0.25
	)

	_health_shake_tween.tween_property(
		health_bar,
		"position",
		_health_bar_start_pos + Vector2(-health_shake_distance * 0.5, 0),
		health_shake_duration * 0.2
	)

	_health_shake_tween.tween_property(
		health_bar,
		"position",
		_health_bar_start_pos,
		health_shake_duration * 0.3
	)
	
	update_hud()
#endregion	
	
func update_hud() -> void:
	if health_bar:
		health_bar.max_value = player.health.max_health
		var displayed_hp = player.health.current_health
		#var displayed_hp = move_toward(health_bar.value, player.health.health, health_bar_speed * delta)
		health_bar.value = displayed_hp
		
	if bomb_hud:
		bomb_count_label.text = str(player.number_of_bombs)
		var drop_cooldown = player.drop_cooldown
		bomb_hud.max_value = drop_cooldown
		var target = drop_cooldown

		if !player.can_drop and player.DropRate:
			target = drop_cooldown - player.DropRate.time_left

		var displayed_bomb = move_toward(player.displayed_bomb, target, drop_cooldown * 6.0)
		bomb_hud.value = displayed_bomb
