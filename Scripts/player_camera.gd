extends Camera2D


@export var random_strength: float = 30.0
@export var shake_fade: float = 5.0

var random := RandomNumberGenerator.new()

var shake_strength: float


func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = _random_offset()


func _apply_shake():   # call apply shake during impact
	shake_strength = random_strength


func _random_offset() -> Vector2:
	return Vector2(random.randf_range(-shake_strength, shake_strength), random.randf_range(-shake_strength, shake_strength))
