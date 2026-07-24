extends Area2D
class_name BombProjectile

@export var travel_speed := 2.0
@export var arc_height := 100.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var start_pos: Vector2
var target_pos: Vector2
var weight := 0.0


func _ready() -> void:
	# The player has already positioned the bomb at the muzzle.
	start_pos = global_position


func _physics_process(delta: float) -> void:
	weight += travel_speed * delta
	weight = clamp(weight, 0.0, 1.0)

	var current_pos = start_pos.lerp(target_pos, weight)

	# Arc
	current_pos.y -= sin(weight * PI) * arc_height

	global_position = current_pos

	if weight >= 1.0:
		_explode()


func _explode() -> void:
	if animation_player.is_playing():
		return

	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()
