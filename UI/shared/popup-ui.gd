extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inputResources: HBoxContainer = get_node("MarginContainer/VBoxContainer/Blueprint/InputResources")
@onready var outputResources: HBoxContainer = get_node("MarginContainer/VBoxContainer/Blueprint/OutputResources")
@onready var title: Label = get_node("MarginContainer/VBoxContainer/PanelContainer/Title")
@onready var type: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Type")
@onready var rarity: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/Rarity")
@onready var description: Label = get_node("MarginContainer/VBoxContainer/PanelContainer2/Description")
@onready var blueprintContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/Blueprint")
@onready var statsContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/Stats")

var element


func _ready():
	resetElements()


func setup(_element):
	element = _element
	resetElements()
	showAdditionalInformation()


func resetElements():
	type.text = ""
	rarity.text = ""
	type.self_modulate = Color.WHITE
	rarity.self_modulate = Color.WHITE
	
	for stat in statsContainer.get_children():
		stat.queue_free()
	for resource in inputResources.get_children():
		resource.get_parent().remove_child(resource)
	for resource in outputResources.get_children():
		resource.get_parent().remove_child(resource)
	
	blueprintContainer.visible = false
	statsContainer.visible = false


func showAdditionalInformation():
	if "name" in element:
		title.text = element.name
	if "description" in element:
		description.text = element.description
	
	if element is InventoryResource:
		type.text = UtilsS.getEnumValue(Enums.resourceType, element.type) + " / "
		rarity.text = UtilsS.getEnumValue(Enums.resourceRarity, element.rarity)
		rarity.self_modulate = UtilsS.getRarityColor(element.rarity)
	
	match element.type:
		Enums.resourceType.BLUEPRINT:
			blueprintContainer.visible = true
			description.text = "This blueprint can be used to craft: " + UtilsS.resourceNameArrayToString(element.outputResources)
			for inputResource in element.inputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				inputResources.add_child(resourceIcon)
				resourceIcon.setup(inputResource.resource, inputResource.amount, inputResource.resource.texture, true, true)
				
			for outputResource in element.outputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				outputResources.add_child(resourceIcon)
				resourceIcon.setup(outputResource.resource, outputResource.amount, outputResource.resource.texture, true, false)
		
		Enums.resourceType.WEAPON:
			statsContainer.visible = true
			if element is MeleeWeapon:
				var damageValue: float = element.damage * (1 + UtilsS.calculateMeleeScaling(playerScene.entityResource) * 0.05) * playerScene.meleeDamageModifier * playerScene.damageModifier
				var damage: String = str(round(playerScene.damageRangeMin * damageValue)) + " - " + str(round(playerScene.damageRangeMax * damageValue))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage", damage)
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Attack Delay.png"), "Attack Delay", str(UtilsS.round(element.attackDelay * playerScene.attackDelayModifier, 2)))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback", str(element.knockback))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Stamina Cost.png"), "Stamina Cost", str(element.staminaCost * playerScene.staminaCostModifier))
			
			if element is RangedWeapon:
				var damage: String = ""
				if element.ammunition:
					var damageValue: float = element.damageModifier * element.ammunition.damage * (1 + UtilsS.calculateRangedScaling(playerScene.entityResource) * 0.05) * playerScene.rangedDamageModifier * playerScene.damageModifier
					damage = str(round(playerScene.damageRangeMin * damageValue)) + " - " + str(round(playerScene.damageRangeMax * damageValue))
				else:
					damage = "No Ammo"
				
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage with Ammunition", damage)
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage Modifier", str(element.damageModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Attack Delay.png"), "Attack Delay", str(UtilsS.round(element.attackDelay * playerScene.attackDelayModifier, 2)))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Speed.png"), "Speed Modifier", str(element.speedModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback Modifier", str(element.knockbackModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Spread.png"), "Spread", str(element.spread))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Number of Projectiles.png"), "Number of Projectiles", str(element.projectileAmount))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Stamina Cost.png"), "Stamina Cost", str(element.staminaCost * playerScene.staminaCostModifier))
			
			addStatusEffectDecriptions()
		
		Enums.resourceType.AMMUNITION:
			statsContainer.visible = true
			var damageValue: float = element.damage * (1 + UtilsS.calculateRangedScaling(playerScene.entityResource) * 0.05) * playerScene.rangedDamageModifier
			var damage: String = str(round(playerScene.damageRangeMin * damageValue)) + " - " + str(round(playerScene.damageRangeMax * damageValue))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage", damage)
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Speed.png"), "Speed", str(element.speed))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback", str(element.knockback))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Piercing.png"), "Piercing", "Yes" if element.isPiercing else "No")
			
			addStatusEffectDecriptions()
		
		Enums.resourceType.EQUIPMENT:
			statsContainer.visible = true
			for modifier in element.modifiers:
				addStatsElement(load("res://assets/UI/icons/entities/player/stats/" + UtilsS.getEnumValue(Enums.equipmentModifierType, modifier.type) + ".png"), UtilsS.getEnumValue(Enums.equipmentModifierType, modifier.type), "+ " + str(modifier.value))
		
		Enums.resourceType.CONSUMABLE:
			statsContainer.visible = true
			addStatsElement(preload("res://assets/UI/icons/entities/player/Cooldown.png"), "Cooldown", str(element.cooldown))
			addStatusEffectDecriptions()
		
		Enums.resourceType.STATUS_EFFECT:
			title.text = UtilsS.getEnumValue(Enums.statusEffectType, element.effectType)
			description.text = UtilsS.getStatusEffectDescription(element)
			type.text = "Strength: " + str(round(element.accumulatedStrength))
			rarity.text = " / Remaining Duration: " + str(round(element.maxRemainingDuration))
			type.self_modulate = UtilsS.colorPrimary
		
		Enums.resourceType.MAP_LOCATION:
			statsContainer.visible = true
			type.text = "Danger Level: "
			rarity.text = str(element.tier)
			rarity.self_modulate = UtilsS.colorPrimary
			if element.locationType != Enums.locationType.NONE:
				addStatsElement(preload("res://assets/UI/icons/menu/map/Information.png"), "Known Information", UtilsS.getEnumValue(Enums.locationType, element.locationType))
			if !element.attributes.is_empty():
				addStatsElement(preload("res://assets/UI/icons/menu/map/Hazards.png"), "Hazards present", UtilsS.enumArrayToString(Enums.locationAttribute, element.attributes))
		
		Enums.resourceType.MAP_PATHWAY:
			statsContainer.visible = true
			type.text = "Danger Level: "
			rarity.text = str(element.tier)
			rarity.self_modulate = UtilsS.colorPrimary
			if !element.attributes.is_empty():
				addStatsElement(preload("res://assets/UI/icons/menu/map/Hazards.png"), "Hazards present", UtilsS.enumArrayToString(Enums.locationAttribute, element.attributes))


func addStatusEffectDecriptions():
	if !element.statusEffects.is_empty():
		addEmptyElement()
		for effect in element.statusEffects:
			var extension: String = " / s" if effect.effectApplyType == Enums.effectApplyType.TICK else ""
			var description: String = str(UtilsS.round(effect.strength * playerScene.effectStrengthModifier, 2)) + extension + " for " + str(effect.duration) + " s"
			addStatsElement(load("res://assets/UI/icons/entities/status-effects/" + UtilsS.getEnumValue(Enums.statusEffectType, effect.effectType) + ".png"), \
				"Applies " + UtilsS.getEnumValue(Enums.statusEffectType, effect.effectType) + " to " + UtilsS.getEnumValue(Enums.statusEffectReceiver, effect.appliesTo), description)


func addEmptyElement():
	var statsElement = preload("res://UI/shared/popup-stat-ui.tscn").instantiate()
	statsContainer.add_child(statsElement)


func addStatsElement(icon: Texture2D, stat: String, description: String):
	var statsElement = preload("res://UI/shared/popup-stat-ui.tscn").instantiate()
	statsContainer.add_child(statsElement)
	statsElement.setup(icon, stat, description)


func update():
	resetElements()
	setup(element)





