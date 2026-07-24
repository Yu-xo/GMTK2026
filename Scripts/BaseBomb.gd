extends Area2D
class_name BaseBomb

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var explosion_delay: float = 0.3
@export var explosion_time: float = 1.0
@export var knockback: float = 400.0

var max_damage: int = 400
var explosion_radius: float = 70.0


func _ready() -> void:
	
	collision.shape = collision.shape.duplicate()
	collision.shape.radius = 0.0

	_start_tick()


func _start_tick():

	await get_tree().create_timer(explosion_delay).timeout

	var tween := create_tween()
	tween.tween_property(collision.shape, "radius", explosion_radius, explosion_time)

	await tween.finished

	for body in get_overlapping_bodies():
		if body.has_method("_hit"):
			var push_dir = (body.global_position - global_position).normalized()
			body._hit(max_damage, knockback, push_dir, 0.5)

	queue_free()

func _on_body_entered(body: Node2D) -> void:

	if body.has_method("_hit"):

		var push_dir := (body.global_position - global_position).normalized()

		body._hit(
			max_damage,
			knockback,
			push_dir,
			0.5
		)
