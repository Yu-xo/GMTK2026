extends Node2D

var enemy_scene: Array[PackedScene] = [preload("uid://dxf7nvtn0td7k"),
preload("uid://b2dk223mp3erv"),
preload("uid://udbwv1trouo1")]

enum EnemyType {MELEE, RANGE, TANK}
enum SpawnPattern {ASCENDING, MIX, BOTH}


@export var melee_wave: Array[int] = [3, 2, 2]
@export var range_wave: Array[int] = [0, 1, 2]
@export var tank_wave: Array[int] = [0, 0, 2]

@export var spawn_time: Array[float] = [2.0, 6.0, 10.0]

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")

var spawn_markers: Array[Node] = []
var spawned_enemies: Array[CharacterBody2D]
var round_num: int = 0

func _ready() -> void:
	_register_spawn_markers()
	#_setup_timers()
	_start_next_round(round_num)


func _register_spawn_markers() -> void:
	spawn_markers = get_tree().get_nodes_in_group("spawn_marker")


#func _setup_timers() -> void:
	#for i in range(spawn_time.size()):
		#var timer: Timer = Timer.new()
		#add_child(timer)
		#timer.one_shot = true
		#timer.start(spawn_time[i])
		#timer.timeout.connect(_spawn_enemy.bind(melee_wave[i], range_wave[i], tank_wave[i]))


func _spawn_enemy(round_param: int) -> void:
	for i in range(melee_wave[round_param]):
		await get_tree().create_timer(0.5).timeout
		var enemy: CharacterBody2D = enemy_scene[0].instantiate()
		spawned_enemies.append(enemy)
		enemy.position = _spawn_position()
		get_parent().add_child.call_deferred(enemy)   # Might need to change get_tree() later
		
	for i in range(range_wave[round_param]):
		await get_tree().create_timer(1).timeout
		var enemy: CharacterBody2D = enemy_scene[1].instantiate()
		spawned_enemies.append(enemy)
		enemy.position = _spawn_position()
		get_parent().add_child.call_deferred(enemy)   # Might need to change get_tree() later
	
	for i in range(tank_wave[round_param]):
		await get_tree().create_timer(2).timeout
		var enemy: CharacterBody2D = enemy_scene[2].instantiate()
		spawned_enemies.append(enemy)
		enemy.position = _spawn_position()
		get_parent().add_child.call_deferred(enemy)   # Might need to change get_tree() later


func _enemy_killed(enemy:CharacterBody2D) -> void:
	spawned_enemies.erase(enemy)
	if spawned_enemies.is_empty():
		round_num += 1
		# end round and bring up upgrade ui


func _start_next_round(round_param: int) -> void:
	await get_tree().create_timer(2).timeout
	_spawn_enemy(round_param)


func _spawn_position() -> Vector2:
	var spawn_pos: Vector2
	var selected_marker: Node2D = spawn_markers.pick_random()
	while (player.position - selected_marker.position).length() < 300:
		selected_marker = spawn_markers.pick_random()
		
	spawn_pos = selected_marker.position + Vector2(randi_range(0, 75), randi_range(0, 75))
	return spawn_pos


#func _spawn_enemy(melee_num: int, range_num: int, tank_num: int) -> void:
	#var furtherst_marker_position: Vector2
	#var furtherst_marker_distance: float = 0
	#for marker: Marker2D in spawn_markers:                 # finding the further spawn point
		#var distance: float = (player.position - marker.position).length()
		#
		#if distance > furtherst_marker_distance:
			#furtherst_marker_distance = distance
			#furtherst_marker_position = marker.position
			#
	#for i in range(melee_num):
		#var enemy: CharacterBody2D = enemy_scene[0].instantiate()
		#spawned_enemies.append(enemy)
		#enemy.position = furtherst_marker_position + Vector2(randi_range(0, 75), randi_range(0, 75))
		#get_parent().add_child(enemy)   # Might need to change get_tree() later
	#
	#for i in range(range_num):
		#var enemy: CharacterBody2D = enemy_scene[1].instantiate()
		#spawned_enemies.append(enemy)
		#enemy.position = furtherst_marker_position + Vector2(randi_range(0, 75), randi_range(0, 75))
		#get_parent().add_child(enemy)   # Might need to change get_tree() later
	#
	#for i in range(tank_num):
		#var enemy: CharacterBody2D = enemy_scene[2].instantiate()
		#spawned_enemies.append(enemy)
		#enemy.position = furtherst_marker_position + Vector2(randi_range(0, 75), randi_range(0, 75))
		#get_parent().add_child(enemy)   # Might need to change get_tree() later
