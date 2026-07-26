extends Area2D

var projectile_direction: Vector2 = Vector2.ZERO

@export var projectile_speed: int = 300
@export var damage: int = 1
@export var projectile_range: int = 1000
@export var knockback: float = 250.0
@export var animated_sprite_2d: AnimatedSprite2D

var distance_travelled: float = 0.0


func _physics_process(delta: float) -> void:
	position += projectile_direction * projectile_speed * delta
	distance_travelled += projectile_speed * delta

	if distance_travelled > projectile_range:
		call_deferred("queue_free")


func _setup(proj_pos: Vector2, proj_dir: Vector2) -> void:
	position = proj_pos + proj_dir * 15
	projectile_direction = proj_dir

	
	if proj_dir != Vector2.ZERO:
		rotation = proj_dir.angle()


func _on_body_entered(hit_object: Node2D) -> void:

	if hit_object.is_in_group("player"):

		var push_dir = projectile_direction.normalized()

		hit_object._hit_player(damage, knockback, push_dir)

		call_deferred("queue_free")
