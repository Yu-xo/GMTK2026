extends Node
class_name HealthController

signal on_damaged(amount)
signal on_death
signal on_health_changed(current, max)

@export var max_health := 300
@export var invincible := false

var current_health := max_health

func _ready() -> void:
	set_health_to_max()

func set_health_to_max():
	set_current_health(max_health)

func take_damage(damage: int):
	if invincible:
		damage = 0
	
	set_current_health(current_health - damage)
	on_damaged.emit(damage)

	if !is_alive():
		on_death.emit()

func set_current_health(amount: int):
	current_health = max(amount, 0)
	on_health_changed.emit(current_health, max_health)
	
func is_alive() -> bool:
	return current_health > 0
