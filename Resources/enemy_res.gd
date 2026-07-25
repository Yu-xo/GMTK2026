extends Resource
class_name EnemyResource

enum EnemyType {MELEE, RANGE, TANK}
enum EnemyState {IDLE, CHASE, ATTACK,REPOSITION}

@export var enemy_type: EnemyType = EnemyType.MELEE
@export var enemy_state: EnemyState = EnemyState.CHASE
@export var hp: int = 3
@export var movespeed: int = 50

@export var chase_range: int = 500
@export var reposition_time: float = 3.0
@export var shot_cooldown: float = 3.0
@export var can_shoot: bool = true
var reposition_target: Vector2
