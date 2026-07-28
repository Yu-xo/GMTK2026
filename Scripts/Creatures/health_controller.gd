extends Node
class_name HealthController

signal on_damaged(amount)
signal on_death
signal on_health_changed(current, max)

@export var max_health := 5

var health := max_health


func reset():
	health = max_health
	on_health_changed.emit(health, max_health)


func take_damage(amount: int):
	health -= amount
	on_health_changed.emit(health, max_health)
	on_damaged.emit(amount)

	if health <= 0:
		on_death.emit()
