extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inputResources: HBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer/Blueprint/InputResources")
@onready var outputResources: HBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer/Blueprint/OutputResources")
@onready var title: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/PanelContainer/Title")
@onready var type: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Type")
@onready var rarity: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/Rarity")
@onready var description: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/Description")
@onready var blueprintContainer: VBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer/Blueprint")
@onready var statsContainer: VBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer/Stats")

var element
var showAdditionalInfo


func _ready():
	visible = false
	resetElements()


func setup(_element, _showAdditionalInfo: bool):
	element = _element
	showAdditionalInfo = _showAdditionalInfo
	title.text = element.name
	description.text = element.description
	
	resetElements()
	
	if showAdditionalInfo:
		showAdditionalInformation()


func resetElements():
	type.text = ""
	rarity.text = ""
	
	for stat in statsContainer.get_children():
		stat.queue_free()
	for resource in inputResources.get_children():
		resource.get_parent().remove_child(resource)
	for resource in outputResources.get_children():
		resource.get_parent().remove_child(resource)
	
	blueprintContainer.visible = false
	statsContainer.visible = false


func showAdditionalInformation():
	if element is InventoryResource:
		type.text = UtilsS.getEnumValue(Enums.resourceType, element.type) + " / "
		rarity.text = UtilsS.getEnumValue(Enums.resourceRarity, element.rarity)
		rarity.modulate = UtilsS.getRarityColor(element.rarity)
	
	match element.type:
		Enums.resourceType.BLUEPRINT:
			blueprintContainer.visible = true
			description.text = "This blueprint can be used to craft: " + UtilsS.resourceNameArrayToString(element.outputResources)
			for inputResource in element.inputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				inputResources.add_child(resourceIcon)
				resourceIcon.setup(inputResource.resource, inputResource.amount, inputResource.resource.texture, true)
				
			for outputResource in element.outputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				outputResources.add_child(resourceIcon)
				resourceIcon.setup(outputResource.resource, outputResource.amount, outputResource.resource.texture, false)
		
		Enums.resourceType.WEAPON:
			statsContainer.visible = true
			if element is MeleeWeapon:
				var damageValue: float = element.damage * (1 + UtilsS.calculateMeleeScaling(playerScene.entityResource) * 0.05) * playerScene.meleeDamageModifier
				var damage: String = str(round(0.75 * damageValue)) + " - " + str(round(1.25 * damageValue))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage", damage)
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Attack_Delay.png"), "Attack Delay", str(UtilsS.round(element.attackDelay * playerScene.attackDelayModifier, 2)))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback", str(element.knockback))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Stamina_Cost.png"), "Stamina Cost", str(element.staminaCost * playerScene.staminaCostModifier))
			
			if element is RangedWeapon:
				var damage: String = ""
				if element.ammunition:
					var damageValue: float = element.damageModifier * element.ammunition.damage * (1 + UtilsS.calculateRangedScaling(playerScene.entityResource) * 0.05) * playerScene.rangedDamageModifier
					damage = str(round(0.75 * damageValue)) + " - " + str(round(1.25 * damageValue))
				else:
					damage = "No Ammo"
				
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage with Ammunition", damage)
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage Modifier", str(element.damageModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Attack_Delay.png"), "Attack Delay", str(UtilsS.round(element.attackDelay * playerScene.attackDelayModifier, 2)))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Speed.png"), "Speed Modifier", str(element.speedModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback Modifier", str(element.knockbackModifier))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Spread.png"), "Spread", str(element.spread))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Number of Projectiles.png"), "Number of Projectiles", str(element.projectileAmount))
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Stamina_Cost.png"), "Stamina Cost", str(element.staminaCost * playerScene.staminaCostModifier))
			
			addEmptyElement()
			addStatusEffectDecriptions()
		
		Enums.resourceType.AMMUNITION:
			statsContainer.visible = true
			var damageValue: float = element.damage * (1 + UtilsS.calculateRangedScaling(playerScene.entityResource) * 0.05) * playerScene.rangedDamageModifier
			var damage: String = str(round(0.75 * damageValue)) + " - " + str(round(1.25 * damageValue))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Damage.png"), "Damage", damage)
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Speed.png"), "Speed", str(element.speed))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Knockback.png"), "Knockback", str(element.knockback))
			addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Piercing.png"), "Piercing", "Yes" if element.isPiercing else "No")
			addEmptyElement()
			addStatusEffectDecriptions()
		
		Enums.resourceType.EQUIPMENT:
			statsContainer.visible = true
			if element.ferocityModifier != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Ferocity.png"), "Ferocity", "+ " + str(element.ferocityModifier) if element.ferocityModifier > 0 else str(element.ferocityModifier))
			if element.perseveranceModifier != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Perseverance.png"), "Perseverance", "+ " + str(element.perseveranceModifier) if element.perseveranceModifier > 0 else str(element.perseveranceModifier))
			if element.agilityModifier != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Agility.png"), "Agility", "+ " + str(element.agilityModifier) if element.agilityModifier > 0 else str(element.agilityModifier))
			if element.perceptionModifier != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Perception.png"), "Perception", "+ " + str(element.perceptionModifier) if element.perceptionModifier > 0 else str(element.perceptionModifier))
			if element.lightRadius != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Light Radius.png"), "Light Radius", "+ " + str(element.lightRadius) if element.lightRadius > 0 else str(element.lightRadius))
			if element.oxygenCapacity != 0:
				addStatsElement(preload("res://assets/UI/icons/entities/player/stats/Oxygen Capacity.png"), "Oxygen Capacity", "+ " + str(element.oxygenCapacity) if element.oxygenCapacity > 0 else str(element.oxygenCapacity))
		
		Enums.resourceType.CONSUMABLE:
			statsContainer.visible = true
			addStatusEffectDecriptions()
			
		Enums.resourceType.MAP_LOCATION:
			statsContainer.visible = true
			type.text = "Information about this Area: "
			rarity.text = UtilsS.getEnumValue(Enums.locationType, element.locationType)
			rarity.modulate = UtilsS.colorPrimary
			if !element.attributes.is_empty():
				addStatsElement(preload("res://assets/UI/icons/menu/Hazards.png"), "Hazards present", UtilsS.enumArrayToString(Enums.locationAttribute, element.attributes))
			
		Enums.resourceType.MAP_PATHWAY:
			statsContainer.visible = true
			type.text = "Danger Level: "
			rarity.text = str(element.tier)
			rarity.modulate = UtilsS.colorPrimary


func addStatusEffectDecriptions():
	if !element.statusEffects.is_empty():
		for effect in element.statusEffects:
			var description: String = str(round(effect.strength * playerScene.effectStrengthModifier)) + " / s for " + str(effect.duration) + " seconds"
			addStatsElement(load("res://assets/UI/icons/entities/status-effects/" + UtilsS.getEnumValue(Enums.statusEffectType, effect.type) + ".png"), \
				"Applies " + UtilsS.getEnumValue(Enums.statusEffectType, effect.type) + " to " + UtilsS.getEnumValue(Enums.statusEffectReceiver, effect.appliesTo), description)


func addEmptyElement():
	var statsElement = preload("res://UI/shared/popup-stat-ui.tscn").instantiate()
	statsContainer.add_child(statsElement)


func addStatsElement(icon: Texture2D, stat: String, description: String):
	var statsElement = preload("res://UI/shared/popup-stat-ui.tscn").instantiate()
	statsContainer.add_child(statsElement)
	statsElement.setup(icon, stat, description)


func update():
	resetElements()
	setup(element, showAdditionalInfo)




