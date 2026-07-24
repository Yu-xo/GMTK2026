extends Node

# ==========================
# PLAYER STATS
# ==========================

var max_hp : int = 100
var speed : float = 100.0
var throw_range : float = 200.0

# ==========================
# PLAYER ABILITIES
# ==========================

var unlock_dash : bool = false
var unlock_shield : bool = false

# ==========================
# PROJECTILE UPGRADES
# ==========================

var volley_count : int = 1
var double_projectile : bool = false
var spike_count : int = 0
var burst_area : float = 0.0
var explosion_timer : float = 1.0
