extends Control

@onready var panels := [
	$Panel,
	$Panel2,
	$Panel3
]

@onready var name_labels := [
	$Panel/Name,
	$Panel2/Name,
	$Panel3/Name
]

@onready var effect_labels := [
	$Panel/Effect,
	$Panel2/Effect,
	$Panel3/Effect
]

@onready var buttons := [
	$Panel/Button,
	$Panel2/Button2,
	$Panel3/Button3
]

@export var upgrade_info : Array[UpgradeRes]

@onready var player = get_tree().get_first_node_in_group("player")

var current_upgrades : Array[UpgradeRes] = []


func _ready() -> void:
	randomize()

	for i in range(buttons.size()):
		buttons[i].pressed.connect(func(): _on_upgrade_selected(i))

	open_upgrade_screen()


func open_upgrade_screen():
	visible = true

	current_upgrades.clear()

	var available := upgrade_info.duplicate()
	available.shuffle()

	for i in range(3):
		if i < available.size():
			current_upgrades.append(available[i])
		else:
			current_upgrades.append(null)

	_update_labels()


func _update_labels():
	for i in range(3):

		if current_upgrades[i] == null:
			panels[i].visible = false
			continue

		panels[i].visible = true

		name_labels[i].text = current_upgrades[i]._name
		effect_labels[i].text = current_upgrades[i].Info


func _on_upgrade_selected(index: int):

	var upgrade = current_upgrades[index]

	if upgrade == null:
		return

	match upgrade.Type:

		UpgradeRes.UpgardeTypes.HPBOOST:
			UpgardeEffects.max_hp += upgrade.UPhp

		UpgradeRes.UpgardeTypes.SPEEDBOOST:
			UpgardeEffects.max_speed += upgrade.UPspeed

		UpgradeRes.UpgardeTypes.DASHCD:
			UpgardeEffects.dash_cooldown += upgrade.UPdash_cooldown

		UpgradeRes.UpgardeTypes.DASHLENG:
			UpgardeEffects.dash_distance += upgrade.UPdash_distance

		UpgradeRes.UpgardeTypes.BOMBCOUNT:
			UpgardeEffects.bomb_count += upgrade.UPbomb_count

		UpgradeRes.UpgardeTypes.BOMBDROPRATE:
			UpgardeEffects.bomb_drop_rate += upgrade.UPbomb_drop_rate

		UpgradeRes.UpgardeTypes.BOMBRADIUS:
			UpgardeEffects.explosion_radius += upgrade.UPexplosion_radius

		UpgradeRes.UpgardeTypes.BOMBDMG:
			UpgardeEffects.max_dmg += upgrade.UPmax_dmg

	player._update_stats()

	visible = false
