extends Area2D


var projectile_direction: Vector2 = Vector2.ZERO
@export var projectile_speed: int = 300
@export var damage: int = 1
@export var projectile_range: int = 1000

var distance_travelled: float = 0


func _physics_process(delta: float) -> void:
	position += (projectile_direction * projectile_speed * delta)
	distance_travelled += projectile_speed * delta
	
	if distance_travelled > projectile_range:
		call_deferred("queue_free")

	

func _setup(proj_pos: Vector2, proj_dir: Vector2):
	position = proj_pos + proj_dir * 15
	projectile_direction = proj_dir


func _on_body_entered(HitObject: Node2D) -> void:
	# apply damage to target
	call_deferred("queue_free")
