extends Control

@export_group("UI Panels")
@export var panels: Array[Control]

@export_group("UI Labels")
@export var name_labels: Array[RichTextLabel]
@export var effect_labels: Array[RichTextLabel]

@export_group("UI Buttons")
@export var buttons: Array[BaseButton]

@export_group("Card Texture Sides")
@export var front_sides: Array[TextureRect]
@export var back_sides: Array[TextureRect]

@export_group("Upgrade Resources")
@export var upgrade_info: Array[UpgradeRes]

@export_group("Nodes")
@export var WaveSpawner: Node

@onready var player = get_tree().get_first_node_in_group("player")

@onready var open_sound_effect: AudioStreamPlayer2D = $OpenSoundEffect
@onready var finish_sound_effect: AudioStreamPlayer2D = $FinishSoundEffect

var current_upgrades: Array[UpgradeRes]
var original_positions := []
var is_animating: bool = false




func _ready() -> void:
	visible = true
	randomize()

	for i in range(panels.size()):
		if panels[i]:
			original_positions.append(panels[i].position.y)

	for i in range(buttons.size()):
		if buttons[i] == null:
			continue

		var button_index := i
		buttons[i].process_mode = Node.PROCESS_MODE_ALWAYS

		buttons[i].pressed.connect(func():
			_on_button_pressed(button_index)
		)

	open_upgrade_screen()


func _on_button_pressed(index: int) -> void:
	_on_upgrade_selected(index)


func open_upgrade_screen():
	visible = true
	current_upgrades.clear()
	open_sound_effect.play()

	var available := upgrade_info.duplicate()
	available.shuffle()

	for i in range(3):
		if i < available.size():
			current_upgrades.append(available[i])
		else:
			current_upgrades.append(null)

	_update_labels()
	_animate_entry()


func _update_labels():
	for i in range(panels.size()):
		if i >= current_upgrades.size() or current_upgrades[i] == null:
			if panels[i]: panels[i].visible = false
			continue

		if panels[i]: panels[i].visible = true
		if i < name_labels.size() and name_labels[i]:
			name_labels[i].text = current_upgrades[i]._name
		if i < effect_labels.size() and effect_labels[i]:
			effect_labels[i].text = current_upgrades[i].Info


func _animate_entry():
	is_animating = true

	for i in range(panels.size()):
		if i >= current_upgrades.size() or current_upgrades[i] == null:
			continue

		var panel = panels[i]
		var target_y = original_positions[i] if i < original_positions.size() else panel.position.y

		panel.position.y = -panel.size.y - 100.0
		panel.pivot_offset = panel.size / 2.0

		if i < front_sides.size() and front_sides[i]:
			front_sides[i].visible = false
		if i < back_sides.size() and back_sides[i]:
			back_sides[i].visible = true

		panel.scale = Vector2.ONE

		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var delay = i * 0.15

		tween.tween_property(panel, "position:y", target_y, 0.5)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(delay)

		tween.tween_property(panel, "scale:x", 0.0, 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

		tween.tween_callback(func():
			if i < front_sides.size() and front_sides[i]:
				front_sides[i].visible = true
			if i < back_sides.size() and back_sides[i]:
				back_sides[i].visible = false
		)

		tween.tween_property(panel, "scale:x", 1.0, 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		if i == panels.size() - 1 or i == current_upgrades.size() - 1:
			tween.finished.connect(func():
				is_animating = false
			)


func _on_upgrade_selected(index: int):
	if is_animating:
		return

	if index >= current_upgrades.size():
		return

	var upgrade = current_upgrades[index]
	if upgrade == null:
		return

	is_animating = true
	finish_sound_effect.play()
	
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

	if player and player.has_method("_update_stats"):
		player._update_stats()

	_animate_exit()


func _animate_exit():
	var exit_tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	for i in range(panels.size()):
		if i >= current_upgrades.size() or current_upgrades[i] == null or not panels[i].visible:
			continue

		var panel = panels[i]
		var delay = i * 0.08

		var panel_seq = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

		panel_seq.tween_property(panel, "scale:x", 0.0, 0.12)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)\
			.set_delay(delay)

		panel_seq.tween_callback(func():
			if i < front_sides.size() and front_sides[i]:
				front_sides[i].visible = false
			if i < back_sides.size() and back_sides[i]:
				back_sides[i].visible = true
		)

		panel_seq.tween_property(panel, "scale:x", 1.0, 0.12)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		panel_seq.tween_property(panel, "position:y", -panel.size.y - 200.0, 0.4)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_IN)

	exit_tween.finished.connect(func():
		visible = false
		is_animating = false
	)

	if WaveSpawner and WaveSpawner.has_method("start_next_wave"):
		WaveSpawner.start_next_wave()

	get_tree().paused = false


func _refresh():
	open_upgrade_screen()
	visible = true
