extends Area2D
class_name BombProjectile

@export var travel_speed := 2.0
@export var arc_height := 100.0

@onready var player = get_tree().get_first_node_in_group("player")

var start_pos: Vector2
var target_pos: Vector2
var weight := 0.0

func _ready() -> void:
	start_pos = player.global_position
	target_pos = get_global_mouse_position()

	global_position = start_pos

func _physics_process(delta: float) -> void:
	weight += travel_speed * delta
	weight = clamp(weight, 0.0, 1.0)

	var current_pos = start_pos.lerp(target_pos, weight)

	
	current_pos.y -= sin(weight * PI) * arc_height

	global_position = current_pos

	if weight >= 1.0:
		# TODO: gonna spawn explosion here
		queue_free()