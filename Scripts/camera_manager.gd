extends Camera2D
class_name CameraManager
static var instance : CameraManager

@export var random_strength: float = 30.0
@export var shake_fade: float = 5.0

var random := RandomNumberGenerator.new()
var shake_strength := 0.0

func _enter_tree() -> void:
	instance = self

func _ready():
	random.randomize()

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		offset = _random_offset()
	else:
		offset = Vector2.ZERO

func apply_shake(strength := random_strength):
	shake_strength = strength

func _random_offset() -> Vector2:
	return Vector2(
		random.randf_range(-shake_strength, shake_strength),
		random.randf_range(-shake_strength, shake_strength)
	)
