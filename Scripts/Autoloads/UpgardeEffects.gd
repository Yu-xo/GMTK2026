extends Node
class_name UpgardeEffect

var max_hp: int = 3
var max_speed: int = 200

var dash_cooldown: float = 0.6
var dash_distance: float = 0.18

var bomb_count: int = 1
var bomb_drop_rate: float = 1.0

var explosion_radius: float = 70.0
var max_dmg: int = 4

var enemy_speed: float = 100.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
