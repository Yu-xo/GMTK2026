extends CharacterBody2D

@export var enemy_res: EnemyResource
@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")

var move_direction: Vector2
var push_velocity: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	_ai()
	move_and_slide()


func _hit(damage_value: int, push_str: int, push_dir: Vector2, push_dur: float) -> void:
	_take_damage(damage_value)
	var tween: Tween = get_tree().create_tween()
	var push_vel: Vector2 = push_dir.normalized() * push_str
	tween.tween_property(self, "push_velocity", push_vel, 0.1)
	tween.tween_property(self, "push_velocity", Vector2.ZERO, push_dur)



func _take_damage(damage_value: int) -> void:
	enemy_res.hp -= damage_value
	if enemy_res.hp <= 0:
		queue_free()


func _ai() -> void:
	match enemy_res.enemy_type:
		enemy_res.EnemyType.MELEE:
			_ai_melee()
		
		enemy_res.EnemyType.RANGE:
			_ai_range()
			
		enemy_res.EnemyType.TANK:
			_ai_tank()


func _ai_melee() -> void:
	match enemy_res.enemy_state:
		enemy_res.EnemyState.IDLE:
			velocity = Vector2.ZERO
		
		enemy_res.EnemyState.CHASE:
			move_direction = (player.position - position).normalized()
			velocity = (move_direction * enemy_res.movespeed) + push_velocity
			

func _ai_range() -> void:
	match enemy_res.enemy_state:
		enemy_res.EnemyState.IDLE:
			velocity = Vector2.ZERO
	
		enemy_res.EnemyState.CHASE:
			move_direction = (player.position - position).normalized()
			velocity = (move_direction * enemy_res.movespeed) + push_velocity
		

func _ai_tank() -> void:
	match enemy_res.enemy_state:
		enemy_res.EnemyState.IDLE:
			velocity = Vector2.ZERO
	
		enemy_res.EnemyState.CHASE:
			move_direction = (player.position - position).normalized()
			velocity = (move_direction * enemy_res.movespeed) + push_velocity
		
