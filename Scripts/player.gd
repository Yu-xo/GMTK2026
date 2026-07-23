extends CharacterBody2D


enum States {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEAD} # We can add more later
	
var current_state = States.IDLE

var dir : Vector2

@export var Speed := 100


func _physics_process(delta: float) -> void:
	_state_handler(delta)
	move_and_slide()

func _state_handler(delta):
	match current_state:
		States.IDLE:_idle_state()
		States.MOVE:_movemovet_state(delta)
		States.ATTACK:pass
		States.HURT:pass
		States.DEAD:pass

func _idle_state():
	if Input.get_vector("left","right","up","down"):
		current_state = States.MOVE
	else:
		current_state = States.IDLE

func _movemovet_state(delta):
	dir = Input.get_vector("left","right","up","down")
	velocity = dir * Speed
	
	
	if !dir: current_state = States.IDLE
