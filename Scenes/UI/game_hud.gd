extends CanvasLayer
class_name GameHud

var player : PlayerController

@onready var health_bar: TextureProgressBar = $HUDContainer/HealthBar
@onready var bomb_hud: TextureProgressBar = $HUDContainer/BombHud
@onready var bomb_count_label: Label = $HUDContainer/NumberOfBombs

@export var health_bar_speed := 10.0

func _ready() -> void:
	player = PlayerController.instance
	player.health.on_health_changed.connect(_health_changed)
	player.on_dropped_bomb.connect(update_hud)
	update_hud()
	
func _health_changed(_amount: int):
	update_hud()
	
func update_hud() -> void:
	if health_bar:
		health_bar.max_value = player.health.max_hp
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
