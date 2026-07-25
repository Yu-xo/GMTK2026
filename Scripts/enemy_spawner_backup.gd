extends Node2D

var enemy_scene: Array[PackedScene] = [preload("uid://dxf7nvtn0td7k"),
preload("uid://b2dk223mp3erv"),
preload("uid://udbwv1trouo1")]

enum EnemyType {MELEE, RANGE, TANK}
enum SpawnPattern {ASCENDING, MIX, BOTH}


@export var max_enemies: int = 50
@export var enemy_type_ratio: Array[int]
@export var round_time: float = 60.0
@export var spawn_interval_ratio: Array[int]
@export var spawn_pattern: SpawnPattern = SpawnPattern.ASCENDING

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")

var spawn_pool: Array[int] = []
var recalc_spawn: Array[int] = []
var spawn_timers: Array[Timer] = []
var spawn_markers: Array[Node] = []
var spawn_batch_num: Array[int] = []
var spawn_batch_count: int = 0
var spawn_wait_time: float


func _ready() -> void:
	_register_spawn_markers()
	
	if enemy_type_ratio.size() > 3:
		enemy_type_ratio.resize(3)
	
	_calc_spawn_pool()
	_calc_spawn_batch()
	
	# start spawning 3.0s after round start, then after every allowed_spawn_time, final spawn at the mid point of round
	var allowed_spawn_time: float = (round_time / 2) - 3.0
	# number of spawn batches = length of spawn_internal_ratio - 1 (-1 because first spawn is at 3.0s)
	if spawn_interval_ratio.size() > 1:
		spawn_wait_time = allowed_spawn_time / (spawn_interval_ratio.size() - 1)
		$SpawnTimer.wait_time = spawn_wait_time
	$WaitSpawnTimer.start()



func _calc_spawn_pool() -> void:
	var total_ratio: float
	var remainder: int
	var sum_enemies: int
	for ratio in enemy_type_ratio:
		total_ratio += ratio
	
	for ratio in enemy_type_ratio:
		var num_enemies: int = floori(ratio / total_ratio * max_enemies)
		spawn_pool.append(num_enemies)
		sum_enemies += num_enemies
	
	remainder = max_enemies - sum_enemies
	spawn_pool[0] += remainder


func _calc_spawn_batch() -> void:
	var total_ratio: float
	var remainder: int
	var sum_enemies: int
	for ratio in spawn_interval_ratio:
		total_ratio += ratio
	
	for ratio in spawn_interval_ratio:
		var num_enemies: int = floori(ratio / total_ratio * max_enemies)
		spawn_batch_num.append(num_enemies)
		sum_enemies += num_enemies
	
	remainder = max_enemies - sum_enemies
	spawn_batch_num[spawn_batch_num.size()-1] += remainder



func _register_spawn_markers() -> void:
	spawn_markers = get_tree().get_nodes_in_group("spawn_marker")


func _spawn_enemy() -> void:
	var furtherst_marker_position: Vector2
	var furtherst_marker_distance: float = 0
	for marker: Marker2D in spawn_markers:                 # finding the further spawn point
		var distance: float = (player.position - marker.position).length()
		
		if distance > furtherst_marker_distance:
			furtherst_marker_distance = distance
			furtherst_marker_position = marker.position
			
	_spawn_pattern(furtherst_marker_position)


func _spawn_pattern(marker_pos: Vector2) -> void:
	match spawn_pattern:
		SpawnPattern.ASCENDING:
			if spawn_batch_count == 0:
				for i in range(1, spawn_batch_num[spawn_batch_count] + 1, 1):
					var j: int = 0
					if spawn_pool[j] > 0:
						var enemy: CharacterBody2D = enemy_scene[j].instantiate()
						enemy.position = marker_pos + Vector2(randi_range(0, 75), randi_range(0, 75))
						get_parent().add_child(enemy)   # Might need to change get_tree() later
						spawn_pool[j] -= 1
						
			else:
				for i in range(1, spawn_batch_num[spawn_batch_count] + 1, 1):
					var j: int = 0
					if spawn_pool[j] > 0:
						_instantiate_enemy(j, marker_pos)
					else:
						j += 1
						_instantiate_enemy(j, marker_pos)

		SpawnPattern.MIX:
			var random_ratio: Vector3 = Vector3i(randi_range(1,5), randi_range(1,5), randi_range(1,5))
			var total_ratio: float
			var remainder: int
			var sum_enemies: int
			for ratio in random_ratio:
				total_ratio += ratio
			
			for ratio in enemy_type_ratio:
				var num_enemies: int = floori(ratio / total_ratio * max_enemies)
				spawn_pool.append(num_enemies)
				sum_enemies += num_enemies
			
			remainder = max_enemies - sum_enemies
			spawn_pool[0] += remainder


func _instantiate_enemy(pool_category: int, marker_pos: Vector2) -> void:
	var enemy: CharacterBody2D = enemy_scene[pool_category].instantiate()
	enemy.position = marker_pos + Vector2(randi_range(0, 75), randi_range(0, 75))
	get_parent().add_child(enemy)   # Might need to change get_tree() later
	spawn_pool[pool_category] -= 1



func _on_wait_spawn_timer_timeout() -> void:
	_spawn_enemy()
	spawn_batch_count += 1
	if spawn_batch_count < spawn_interval_ratio.size():
		$SpawnTimer.start()


func _on_spawn_timer_timeout() -> void:
	if spawn_batch_count < spawn_interval_ratio.size():
		_spawn_enemy()
		spawn_batch_count += 1
