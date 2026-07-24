extends Node2D

var enemy_scene: Array[PackedScene] = [preload("uid://dxf7nvtn0td7k"),
preload("uid://b2dk223mp3erv"),
preload("uid://udbwv1trouo1")]

func _on_timer_timeout() -> void:
	_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy: CharacterBody2D = enemy_scene[0].instantiate()
	enemy.position = position
	get_parent().add_child(enemy)   # Might need to change get_tree() later
