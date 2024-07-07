extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/InputResources")
@onready var outputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/OutputResources")
@onready var title: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer/Title")
@onready var type: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/Type")
@onready var rarity: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/Rarity")
@onready var description: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer2/Description")
@onready var blueprintContainer: VBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint")
@onready var statsContainer: VBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Stats")

var element
var showAdditionalInfo


func _ready():
	blueprintContainer.visible = false
	statsContainer.visible = false


func setup(_element, _showAdditionalInfo: bool):
	element = _element
	showAdditionalInfo = _showAdditionalInfo
	title.text = element.name
	type.text = UtilsS.getEnumValue(Enums.resourceType, element.type) + " / "
	rarity.text = UtilsS.getEnumValue(Enums.resourceRarity, element.rarity)
	rarity.modulate = UtilsS.getRarityColor(element.rarity)
	description.text = element.description
	
	if showAdditionalInfo:
		match element.type:
			Enums.resourceType.BLUEPRINT:
				blueprintContainer.visible = true
				for resource in element.inputResources:
					var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
					inputResources.add_child(resourceIcon)
					resourceIcon.setup(resource, true, true)
					
				for resource in element.outputResources:
					var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
					outputResources.add_child(resourceIcon)
					resourceIcon.setup(resource, true, false)
			
			Enums.resourceType.WEAPON:
				statsContainer.visible = true
				if element is MeleeWeapon:
					var damageValue: float = element.damage * (1 + UtilsS.calculateMeleeScaling(playerScene.entityResource) * 0.05)
					var damage: String = str(round(0.75 * damageValue)) + " - " + str(round(1.25 * damageValue))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Damage.png"), "Damage", damage)
					addStatsElement(preload("res://assets/UI/icons/player/stats/Attack_Delay.png"), "Attack Delay", str(element.attackDelay))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Knockback.png"), "Knockback", str(element.knockback))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Stamina_Cost.png"), "Stamina Cost", str(element.staminaCost))
					
					var statusEffects: String = ""
					if !element.statusEffects.is_empty():
						for effect in element.statusEffects:
							statusEffects += str(effect.strength) + " " + effect.name + " for " + str(effect.duration) + " seconds"
						#weaponDescription.get_child(1).text = "Applies: " + statusEffects
				
				if element is RangedWeapon:
					var damage: String = ""
					if element.ammunition:
						var damageValue: float = element.damageModifier * element.ammunition.damage * (1 + UtilsS.calculateRangedScaling(playerScene.entityResource) * 0.05)
						damage = str(round(0.75 * damageValue)) + " - " + str(round(1.25 * damageValue))
					else:
						damage = "No Ammunition"

					addStatsElement(preload("res://assets/UI/icons/player/stats/Damage.png"), "Damage with Ammunition", damage)
					addStatsElement(preload("res://assets/UI/icons/player/stats/Damage.png"), "Damage Modifier", str(element.damageModifier))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Attack_Delay.png"), "Attack Delay", str(element.attackDelay))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Speed.png"), "Speed Modifier", str(element.speedModifier))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Knockback.png"), "Knockback Modifier", str(element.knockbackModifier))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Spread.png"), "Spread", str(element.spread))
					addStatsElement(preload("res://assets/UI/icons/player/stats/Stamina_Cost.png"), "Stamina Cost", str(element.staminaCost))

			Enums.resourceType.AMMUNITION:
				statsContainer.visible = true
				addStatsElement(preload("res://assets/UI/icons/player/stats/Damage.png"), "Damage", str(element.damage))
				addStatsElement(preload("res://assets/UI/icons/player/stats/Speed.png"), "Speed", str(element.speed))
				addStatsElement(preload("res://assets/UI/icons/player/stats/Knockback.png"), "Knockback", str(element.knockback))


func addStatsElement(icon: Texture2D, stat: String, description: String):
	var statsElement = preload("res://UI/shared/popup-stat-ui.tscn").instantiate()
	statsContainer.add_child(statsElement)
	statsElement.setup(icon, stat, description)


func update():
	for resource in inputResources.get_children():
		resource.get_parent().remove_child(resource)
	for resource in outputResources.get_children():
		resource.get_parent().remove_child(resource)
	
	setup(element, showAdditionalInfo)





