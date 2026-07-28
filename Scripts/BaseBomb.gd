extends Area2D
class_name BaseBomb

@export_group("Components")
@export var collision: CollisionShape2D
@export var bomb_sprite: AnimatedSprite2D
@export var explosion_particles: CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_area: Sprite2D = $ExplosionArea

@export_group("Audio")
@export var blast_effect: AudioStreamPlayer2D
@export var tick_effect: AudioStreamPlayer2D

@export_group("Explosion Settings")
@export var explosion_delay: float = 2.0
@export var explosion_radius: float = 100.00
@export var explosion_time: float = 0.15

const BASE_RADIUS: float = 70.0

@export_group("Combat")
@export var knockback: float = 400.0
@export var max_damage: int = 1


func _ready() -> void:
	if collision:
		collision.shape = collision.shape.duplicate()
		collision.shape.radius = explosion_radius

	if explosion_area:
		explosion_area.scale = Vector2.ZERO
		var texture_diameter = explosion_area.texture.get_size().x
		var target_size = (explosion_radius * 2.0) / texture_diameter

		var tween := create_tween()
		tween.tween_property(
			explosion_area,
			"scale",
			Vector2.ONE * target_size,
			0.2
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	if explosion_particles:
		explosion_particles.one_shot = true
		explosion_particles.emitting = false

		explosion_particles.amount = 40
		explosion_particles.lifetime = 0.45
		explosion_particles.explosiveness = 1.0

		explosion_particles.direction = Vector2.UP
		explosion_particles.spread = 360.0

		explosion_particles.gravity = Vector2.ZERO

		explosion_particles.angular_velocity_min = -180.0
		explosion_particles.angular_velocity_max = 180.0

		explosion_particles.linear_accel_min = -100.0
		explosion_particles.linear_accel_max = 100.0

		_update_particle_scaling()

	_start_tick()


func _update_particle_scaling() -> void:
	if explosion_particles == null:
		return

	var radius_ratio: float = explosion_radius / BASE_RADIUS

	explosion_particles.initial_velocity_min = 180.0 * radius_ratio
	explosion_particles.initial_velocity_max = 250.0 * radius_ratio

	explosion_particles.scale_amount_min = 2.0 * sqrt(radius_ratio)
	explosion_particles.scale_amount_max = 4.0 * sqrt(radius_ratio)


func _start_tick() -> void:
	var elapsed := 0.0
	var tick_delay := 0.35

	while elapsed < explosion_delay:
		_play_tick_sound(tick_delay)
		_tick_animation(tick_delay)

		await get_tree().create_timer(tick_delay).timeout

		elapsed += tick_delay
		tick_delay = max(0.08, tick_delay - 0.04)

	_explode()


func _play_tick_sound(current_delay: float) -> void:
	if tick_effect:
		var progress = tick_delay_ratio(current_delay)
		tick_effect.pitch_scale = lerp(1.0, 1.5, progress)
		tick_effect.play()


func _tick_animation(duration: float) -> void:
	if bomb_sprite == null:
		return

	var angle = lerp(6.0, 18.0, 1.0 - tick_delay_ratio(duration))

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		bomb_sprite,
		"rotation_degrees",
		angle,
		duration * 0.5
	)

	tween.tween_property(
		bomb_sprite,
		"rotation_degrees",
		-angle,
		duration * 0.5
	)

	tween.tween_property(
		bomb_sprite,
		"rotation_degrees",
		0.0,
		0.02
	)


func tick_delay_ratio(duration: float) -> float:
	return clamp((0.35 - duration) / (0.35 - 0.08), 0.0, 1.0)


func _explode() -> void:
	if tick_effect and tick_effect.playing:
		tick_effect.stop()

	if blast_effect:
		blast_effect.play()

	if bomb_sprite:
		bomb_sprite.visible = false
		
	explosion_area.visible = false

	if explosion_particles:
		_update_particle_scaling()
		explosion_particles.restart()
		explosion_particles.emitting = true

	CameraManager.instance.apply_shake(5)
	
	if collision:
		var bodies = get_overlapping_bodies()

		for body in bodies:
			var push_dir = (body.global_position - global_position).normalized()

			if body.has_method("_hit"):
				body._hit(
					max_damage,
					knockback,
					push_dir,
					0.5
				)

			elif body.is_in_group("player"):
				PlayerController.instance.hit_player(
					max_damage,
					knockback,
					push_dir
				)

	var max_wait_time := 0.0

	if explosion_particles:
		max_wait_time = max(max_wait_time, explosion_particles.lifetime)

	if blast_effect and blast_effect.stream:
		max_wait_time = max(max_wait_time, blast_effect.stream.get_length())

	if max_wait_time > 0.0:
		await get_tree().create_timer(max_wait_time).timeout

	queue_free()
