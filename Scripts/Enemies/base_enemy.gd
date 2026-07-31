extends CharacterBody2D

signal enemy_died

@export var enemy_res: EnemyResource

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

@export var projectile_scene: PackedScene

# Animation
@export var animate: AnimatedSprite2D

@export var idle_anim: String = "idle"
@export var walk_anim: String = "walk"
@export var attack_anim: String = "attack"

var move_direction: Vector2
var push_velocity: Vector2 = Vector2.ZERO

var can_attack := true

@onready var hit_sound_effect: AudioStreamPlayer2D = $OnHitSoundEffect
var attack_sound_effect: AudioStreamPlayer2D


func _ready() -> void:
	enemy_res = enemy_res.duplicate(true)

	add_to_group("enemy")

	if animate:
		animate.play(idle_anim)

	match enemy_res.enemy_type:
		enemy_res.EnemyType.RANGE:
			$ShotCooldownTimer.wait_time = enemy_res.shot_cooldown
			$RepositionTimer.wait_time = enemy_res.reposition_time
			attack_sound_effect = $AttackSoundEffect

	match enemy_res.enemy_type:
		enemy_res.EnemyType.TANK:
			$RushCooldownTimer.wait_time = enemy_res.rush_cooldown
			$RepositionTimer.wait_time = enemy_res.reposition_time
			attack_sound_effect = $AttackSoundEffect





func _physics_process(_delta: float) -> void:
	_ai()
	look_direction()
	move_and_slide()


func _hit(damage_value: int, push_str: int, push_dir: Vector2, push_dur: float) -> void:
	_take_damage(damage_value)

	var tween: Tween = get_tree().create_tween()
	var push_vel: Vector2 = push_dir.normalized() * push_str

	tween.tween_property(self, "push_velocity", push_vel, 0.1)
	tween.tween_property(self, "push_velocity", Vector2.ZERO, push_dur)
func look_direction():
	if move_direction.x < 0.0: animate.flip_h = true
	elif move_direction.x > 0.0: animate.flip_h = false


func _take_damage(damage_value: int) -> void:
	enemy_res.hp -= damage_value
	hit_sound_effect.play()

	DamageNumber._display_number(damage_value, $Marker2D.global_position)

	if enemy_res.hp <= 0:
		enemy_died.emit()
		
		EnemySpawner.instance._enemy_killed(self)
		_die_animation()
		
func _die_animation() -> void:
	set_physics_process(false)
	set_process(false)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

	var tween = create_tween()

	# Pop outward
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.05)

	# Then disappear quickly
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)

	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.12)

	await tween.finished

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
	add_to_group("enemy")
	match enemy_res.enemy_state:

		enemy_res.EnemyState.IDLE:

			velocity = Vector2.ZERO

			if animate.animation != idle_anim:
				animate.play(idle_anim)

		enemy_res.EnemyState.CHASE:

			move_direction = (player.position - position).normalized()

			velocity = (move_direction * enemy_res.movespeed) + push_velocity

			#if animate.animation != walk_anim:
				#animate.play(walk_anim)


func _ai_range() -> void:
	add_to_group("enemy")
	match enemy_res.enemy_state:

		enemy_res.EnemyState.IDLE:

			velocity = Vector2.ZERO

			if animate.animation != idle_anim:
				animate.play(idle_anim)

		enemy_res.EnemyState.CHASE:

			#if animate.animation != walk_anim:
				#animate.play(walk_anim)

			if (player.position - position).length() > enemy_res.chase_range * randf_range(0.75, 1.0):

				move_direction = (player.position - position).normalized()

				velocity = (move_direction * enemy_res.movespeed) + push_velocity

			else:

				enemy_res.enemy_state = enemy_res.EnemyState.ATTACK

		enemy_res.EnemyState.ATTACK:

			velocity = Vector2.ZERO

			if animate.animation != attack_anim:
				animate.play(attack_anim)
				await animate.animation_finished

			if enemy_res.can_shoot:
				attack_sound_effect.play()
				var projectile = projectile_scene.instantiate() as Area2D

				get_tree().current_scene.add_child(projectile)

				if projectile.has_method("_setup"):
					projectile._setup(position, (player.position - position).normalized())

				enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION
				enemy_res.can_shoot = false

				$ShotCooldownTimer.start()
				$RepositionTimer.start()

				enemy_res.reposition_target = player.position + Vector2(
					randf_range(-50, 50),
					randf_range(-50, 50)
				)

			else:

				enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION

				if $RepositionTimer.is_stopped():

					$RepositionTimer.start()

					enemy_res.reposition_target = player.position + Vector2(
						randf_range(-50, 50),
						randf_range(-50, 50)
					)

		enemy_res.EnemyState.REPOSITION:

			if animate.animation != walk_anim:
				animate.play(walk_anim)

			move_direction = (enemy_res.reposition_target - position).normalized()

			velocity = (move_direction * enemy_res.movespeed) + push_velocity
func _ai_tank() -> void:
	add_to_group("enemy")
	match enemy_res.enemy_state:

		enemy_res.EnemyState.IDLE:

			velocity = Vector2.ZERO

			if animate.animation != idle_anim:
				animate.play(idle_anim)

		enemy_res.EnemyState.CHASE:

			if animate.animation != walk_anim:
				animate.play(walk_anim)

			if (player.position - position).length() > enemy_res.chase_range * randf_range(0.75, 1.0):

				move_direction = (player.position - position).normalized()

				velocity = (move_direction * enemy_res.movespeed) + push_velocity

			else:

				enemy_res.rush_position = player.position + ((player.position - position).normalized() * 50)
				enemy_res.enemy_state = enemy_res.EnemyState.ATTACK

		enemy_res.EnemyState.ATTACK:

			velocity = Vector2.ZERO

			if animate.animation != attack_anim:
				animate.play(attack_anim)
				await animate.animation_finished

			if enemy_res.can_rush:

				if (enemy_res.rush_position - position).length() > enemy_res.rush_range * randf_range(0.75, 1.0):

					move_direction = (enemy_res.rush_position - position).normalized()

					velocity = move_direction * enemy_res.rush_speed
					attack_sound_effect.play()


				else:

					enemy_res.can_rush = false

					enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION

					$RushCooldownTimer.start()
					$RepositionTimer.start()

					enemy_res.reposition_target = player.position + Vector2(
						randf_range(-500, 500),
						randf_range(-500, 500)
					)

			else:

				enemy_res.enemy_state = enemy_res.EnemyState.REPOSITION

				if $RepositionTimer.is_stopped():

					$RepositionTimer.start()

					enemy_res.reposition_target = player.position + Vector2(
						randf_range(-50, 50),
						randf_range(-50, 50)
					)

		enemy_res.EnemyState.REPOSITION:

			if animate.animation != walk_anim:
				animate.play(walk_anim)

			move_direction = (enemy_res.reposition_target - position).normalized()

			velocity = (move_direction * enemy_res.movespeed) + push_velocity


func _on_shot_cooldown_timer_timeout() -> void:
	enemy_res.can_shoot = true


func _on_reposition_timer_timeout() -> void:
	enemy_res.enemy_state = enemy_res.EnemyState.CHASE


func _on_rush_cooldown_timer_timeout() -> void:
	enemy_res.can_rush = true

func _on_hit_box_body_entered(body: Node2D) -> void:
	if !enemy_res.can_attack:
		return
		
	# Check if we're colliding with the player
	if body != player:
		print("Not player")
		return
		
	print("Player")
	enemy_res.can_attack = false

	var push_dir := (body.global_position - global_position).normalized()

	body.hit_player(
		enemy_res.contact_damage,
		enemy_res.knockback,
		push_dir,
	)

	get_tree().create_timer(enemy_res.attack_cooldown).timeout.connect(
		func(): enemy_res.can_attack = true
	)
