extends Resource
class_name UpgradeRes

enum UpgardeTypes {HPBOOST , SPEEDBOOST , DASHCD , DASHLENG , 
BOMBCOUNT , BOMBDROPRATE , BOMBRADIUS , BOMBDMG}

@export var Info : String

@export var Type : UpgardeTypes

@export var UPspeed : int
@export var UPhp : int
@export var UPdash_cooldown : float
@export var UPdash_distance : float
@export var UPbomb_count : int
@export var UPbomb_drop_rate : float
@export var UPexplosion_radius : float
@export var UPmax_dmg : int
