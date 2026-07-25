extends CharacterBody2D

signal enemy_died

@export var OrbNode  = preload("res://Scenes/Obejcts/Orbs.tscn")
@export var enemy_res: EnemyResource
@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
@export var projectile_scene: PackedScene

var move_direction: Vector2
var push_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	enemy_res = enemy_res.duplicate(true)

	match enemy_res.enemy_type:
		enemy_res.EnemyType.RANGE:
			$ShotCooldownTimer.wait_time = enemy_res.shot_cooldown
			$RepositionTimer.wait_time = enemy_res.reposition_time


func _spawn_orb():
	var orb  = OrbNode.instantiate()
	orb.position = self.global_position
	get_tree().current_scene.add_child(orb)


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
		enemy_died.emit()
		_spawn_orb()
		queue_free()

func _ai() -> void:
	match enemy_res.enemy_type:
		enemy_res.EnemyType.MELEE:
			_ai_melee()
		
		enemy_res.EnemyType.RANGE:
			#print(enemy_res.enemy_state)
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
			if (player.position - position).length() > enemy_res.chase_range * randf_range(0.75, 1.0):
				move_direction = (player.position - position).normalized()
				velocity = (move_direction * enemy_res.movespeed) + push_velocity
				
			else:
				enemy_res.enemy_state = enemy_res.EnemyState.ATTACK
				
		enemy_res.EnemyState.ATTACK:
			if enemy_res.can_shoot:
				var projectile = projectile_scene.instantiate() as Area2D
				get_tree().current_scene.add_child(projectile)
		
				if projectile.has_method("_setup"):
					projectile._setup(position, (player.position - position).normalized())
				
				enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION
				enemy_res.can_shoot = false
				$ShotCooldownTimer.start()
				$RepositionTimer.start()
				enemy_res.reposition_target = position * Vector2(1 * randf_range(-20, 20), 1 * randf_range(-20, 20))

			
			else:
				enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION
				if $RepositionTimer.is_stopped():
					$RepositionTimer.start()
					enemy_res.reposition_target = position + Vector2(1 * randf_range(-50, 50), 1 * randf_range(-50, 50))

					
		enemy_res.EnemyState.REPOSITION:
			move_direction = (enemy_res.reposition_target - position).normalized()
			velocity = (move_direction * enemy_res.movespeed) + push_velocity



func _ai_tank() -> void:
	match enemy_res.enemy_state:
		enemy_res.EnemyState.IDLE:
			velocity = Vector2.ZERO

	
		enemy_res.EnemyState.CHASE:
			move_direction = (player.position - position).normalized()
			velocity = (move_direction * enemy_res.movespeed) + push_velocity
		




func _on_shot_cooldown_timer_timeout() -> void:
	enemy_res.can_shoot = true


func _on_reposition_timer_timeout() -> void:
	enemy_res.enemy_state = enemy_res.EnemyState.CHASE
