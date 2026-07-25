extends Resource
class_name EnemyResource

enum EnemyType {MELEE, RANGE, TANK}
enum EnemyState {IDLE, CHASE, ATTACK, REPOSITION}

@export var enemy_type: EnemyType = EnemyType.MELEE
@export var enemy_state: EnemyState = EnemyState.CHASE
@export var hp: int = 3
@export var movespeed: int = 50
@export var push_resistance: int = 50

@export var chase_range: int = 500
@export var reposition_time: float = 3.0
@export var shot_cooldown: float = 3.0
var can_shoot: bool = true
var reposition_target: Vector2


@export var rush_speed: int = 500
@export var rush_cooldown: float = 5.0
@export var rush_range: int = 5
var rush_position: Vector2
var can_rush: bool = true
