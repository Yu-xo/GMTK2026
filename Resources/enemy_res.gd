extends Resource
class_name EnemyResource

enum EnemyType {MELEE, RANGE, TANK}
enum EnemyState {IDLE, CHASE}

@export var enemy_type: EnemyType = EnemyType.MELEE
@export var enemy_state: EnemyState = EnemyState.CHASE
@export var hp: int = 3
@export var movespeed: int = 50
