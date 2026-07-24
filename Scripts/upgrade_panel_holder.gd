extends Control

var current_upgrade

@export var _name: Label
@export var effect: Label
@export var button: Button

@export var UpgradeInfo: Array[UpgardeInformation]


func _ready() -> void:
	UpgradeInfo.shuffle()
	current_upgrade = UpgradeInfo.pop_at(0)

	print(current_upgrade)

	button.pressed.connect(_on_button_pressed)

	_update_upgrade_ui()


func _update_upgrade_ui():

	match current_upgrade.Type:

		UpgardeInformation.AbilityType.HPBOOST:
			_name.text = "HP Boost"
			effect.text = "+" + str(current_upgrade.hp) + " Max HP"

		UpgardeInformation.AbilityType.SPEEDBOOST:
			_name.text = "Speed Boost"
			effect.text = "+" + str(current_upgrade.speed) + " Speed"

		UpgardeInformation.AbilityType.DASHABILITY:
			_name.text = "Dash Ability"
			effect.text = "Unlock Dash\n+" + str(current_upgrade.dash_speed) + " Dash Speed"

		UpgardeInformation.AbilityType.THROWRANGE:
			_name.text = "Throw Range"
			effect.text = "+" + str(current_upgrade.throw_range) + " Throw Range"

		UpgardeInformation.AbilityType.SHIELDEFFECT:
			_name.text = "Shield"
			effect.text = "Unlock Shield\n+" + str(current_upgrade.shield_duration) + "s Duration"

		UpgardeInformation.AbilityType.VOLLYPROJECTILE:
			_name.text = "Volley Projectile"
			effect.text = "+" + str(current_upgrade.volly_count) + " Projectiles"

		UpgardeInformation.AbilityType.DOUBLEPROJECTILE:
			_name.text = "Double Projectile"
			effect.text = "Throw Two Bombs"

		UpgardeInformation.AbilityType.SPIKEPROJECTILE:
			_name.text = "Spike Projectile"
			effect.text = "+" + str(current_upgrade.number_of_spikes) + " Spikes"

		UpgardeInformation.AbilityType.BURSTPROJECTILE:
			_name.text = "Burst Projectile"
			effect.text = "+" + str(current_upgrade.area_of_dmg) + " Explosion Radius"

		UpgardeInformation.AbilityType.EXPLOSIONTIMER:
			_name.text = "Explosion Timer"
			effect.text = "-" + str(current_upgrade.explosiontimer) + "s Explosion Delay"


func _on_button_pressed():

	match current_upgrade.Type:

		UpgardeInformation.AbilityType.HPBOOST:
			StatEffects.max_hp += current_upgrade.hp

			print("HP Upgrade Applied!")
			print("Current Max HP:", StatEffects.max_hp)

		UpgardeInformation.AbilityType.SPEEDBOOST:
			StatEffects.speed += current_upgrade.speed

			print("Speed Upgrade Applied!")
			print("Current Speed:", StatEffects.speed)

		UpgardeInformation.AbilityType.DASHABILITY:
			StatEffects.unlock_dash = true
			StatEffects.dash_speed += current_upgrade.dash_speed
			StatEffects.dash_duration += current_upgrade.dash_duration
			StatEffects.dash_cooldown -= current_upgrade.dash_cooldown

			print("Dash Ability Unlocked!")

		UpgardeInformation.AbilityType.THROWRANGE:
			StatEffects.throw_range += current_upgrade.throw_range

			print("Throw Range Increased!")
			print("Current Throw Range:", StatEffects.throw_range)

		UpgardeInformation.AbilityType.SHIELDEFFECT:
			StatEffects.unlock_shield = true
			StatEffects.shield_duration += current_upgrade.shield_duration
			StatEffects.shield_cooldown -= current_upgrade.shield_cooldown

			print("Shield Ability Unlocked!")

		UpgardeInformation.AbilityType.VOLLYPROJECTILE:
			StatEffects.volley_count += current_upgrade.volly_count

			print("Volley Upgrade Applied!")
			print("Volley Count:", StatEffects.volley_count)

		UpgardeInformation.AbilityType.DOUBLEPROJECTILE:
			StatEffects.double_projectile = true

			print("Double Projectile Unlocked!")

		UpgardeInformation.AbilityType.SPIKEPROJECTILE:
			StatEffects.number_of_spikes += current_upgrade.number_of_spikes

			print("Spike Projectile Upgraded!")
			print("Spike Count:", StatEffects.number_of_spikes)

		UpgardeInformation.AbilityType.BURSTPROJECTILE:
			StatEffects.burst_area += current_upgrade.area_of_dmg

			print("Burst Area Increased!")
			print("Current Burst Area:", StatEffects.burst_area)

		UpgardeInformation.AbilityType.EXPLOSIONTIMER:
			StatEffects.explosion_timer -= current_upgrade.explosiontimer

			print("Explosion Timer Reduced!")
			print("Current Explosion Timer:", StatEffects.explosion_timer)

	queue_free()
