extends Control


signal cardSelected

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var title: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/Title")
@onready var icon: TextureRect = get_node("PanelContainer/MarginContainer/VBoxContainer/PanelContainer/Icon")
@onready var requirementsDescription: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/Requirements/Description")
@onready var requirementsValue: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/Requirements/Value")
@onready var effectDescription: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/Effect/Description")
@onready var effectValue: Label = get_node("PanelContainer/MarginContainer/VBoxContainer/Effect/Value")
@onready var statsContainer: HBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer/Stats")

var card: LevelUpCard
var statIcons: Array[Texture] = [preload("res://assets/UI/icons/entities/player/stats/Ferocity.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perseverance.png"),
	preload("res://assets/UI/icons/entities/player/stats/Agility.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perception.png")]


func setup(_card: LevelUpCard):
	card = _card
	title.text = card.name + " " + getTierLabel(card)
	icon.texture = card.icon
	requirementsDescription.text = "Unlocked by: " if !card.requirements.is_empty() else ""
	requirementsValue.text = getRequirementLabels(card.requirements)
	effectDescription.text = card.description.replace("$", card.name)
	effectValue.text = str(card.value)  + " %"
	for stat in card.stats:
		var instance = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		statsContainer.add_child(instance)
		instance.setup(null, stat.amount, statIcons[stat.resource], false)
		
		var colors = [UtilsS.colorMissing, UtilsS.colorUncommon, UtilsS.colorLegendary, UtilsS.colorRare]
		instance.changeIconColor(colors[stat.resource])
		instance.changeFrameColor(colors[stat.resource])


func getRequirementLabels(requirements: Array[LevelUpCard]):
	var text: String = ""
	for requirement in requirements:
		text += requirement.name + " " + getTierLabel(requirement)
		if requirements.find(requirement) < requirements.size() - 1:
			text += ", "
	return text


func getTierLabel(card: LevelUpCard):
	match card.tier:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"


func _on_button_pressed():
	gainStats()
	gainModifiers()
	cardSelected.emit()
	playerScene.selectedCards.append(card)


func gainModifiers():
	var value: float = card.value / 100
	match card.type:
		Enums.cardType.MELEE_DAMAGE:
			playerScene.meleeDamageModifier += value
		Enums.cardType.RANGED_DAMAGE:
			playerScene.rangedDamageModifier += value
		Enums.cardType.ATTACK_DELAY:
			playerScene.attackDelayModifier -= value
		Enums.cardType.HEALTH:
			playerScene.healthModifier += value
		Enums.cardType.MOVEMENT_SPEED:
			playerScene.movementSpeedModifier += value
		Enums.cardType.SIGHT:
			playerScene.sightRadiusModifier += value
		Enums.cardType.FORTUNE:
			playerScene.lootModifier += value
		Enums.cardType.EFFECT_STRENGTH:
			playerScene.effectStrengthModifier += value
		Enums.cardType.STAMINA_COST:
			playerScene.staminaCostModifier -= value


func gainStats():
	for stat in card.stats:
		match stat.resource:
			Enums.statType.FEROCITY:
				playerScene.entityResource.ferocity += stat.amount
			Enums.statType.PERSEVERANCE:
				playerScene.entityResource.perseverance += stat.amount
			Enums.statType.AGILITY:
				playerScene.entityResource.agility += stat.amount
			Enums.statType.PERCEPTION:
				playerScene.entityResource.perception += stat.amount






