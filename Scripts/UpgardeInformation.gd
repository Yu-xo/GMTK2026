extends Resource
class_name UpgardeInformation

enum AbilityType {
	HPBOOST,
	SPEEDBOOST,
	DASHABILITY,
	THROWRANGE,
	SHIELDEFFECT,

	VOLLYPROJECTILE,
	DOUBLEPROJECTILE,
	SPIKEPROJECTILE,
	BURSTPROJECTILE,
	EXPLOSIONTIMER,
}

@export var Type : AbilityType


@export var hp : int = 0
@export var speed : float = 0.0
@export var throw_range : float = 0.0

@export var dash_speed : float = 0.0
@export var dash_duration : float = 0.0
@export var dash_cooldown : float = 0.0

@export var shield_duration : float = 0.0
@export var shield_cooldown : float = 0.0



@export var volly_count : int = 0
@export var number_of_spikes : int = 0
@export var area_of_dmg : float = 0.0
@export var explosiontimer : float = 0.0
