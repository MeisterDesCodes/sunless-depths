extends Control


signal cardSelected

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var title: Label = get_node("MarginContainer/VBoxContainer/Title")
@onready var icon: TextureRect = get_node("MarginContainer/VBoxContainer/PanelContainer/Icon")
@onready var requirementsDescription: Label = get_node("MarginContainer/VBoxContainer/Requirements/Description")
@onready var requirementsValue: Label = get_node("MarginContainer/VBoxContainer/Requirements/Value")
@onready var effectDescription: Label = get_node("MarginContainer/VBoxContainer/Effect/Description")
@onready var effectValue: Label = get_node("MarginContainer/VBoxContainer/Effect/Value")
@onready var statsContainer: HBoxContainer = get_node("MarginContainer/VBoxContainer/Stats")

var card: LevelUpCard
var statIcons: Array[Texture] = [preload("res://assets/UI/icons/entities/player/stats/Ferocity.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perseverance.png"),
	preload("res://assets/UI/icons/entities/player/stats/Agility.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perception.png")]

var initialPosition: Vector2


func setup(_card: LevelUpCard):
	card = _card
	title.text = card.name + " " + getTierLabel(card)
	icon.texture = card.icon
	requirementsDescription.text = "Unlocked by: " if !card.requirements.is_empty() else ""
	requirementsValue.text = getRequirementLabels(card.requirements)
	effectDescription.text = card.description.replace("$", card.name) + ":"
	
	initialPosition = global_position
	
	var currentStrengthValues: String = str(card.value) + " %" 
	if card.value2 != 0:
		currentStrengthValues += " / " + str(card.value2) + " %" 
	
	var totalStrengthValues: String = ""
	if getTotalStrengthValues(card).V1 != 0:
		totalStrengthValues += " (Total: " + str(getTotalStrengthValues(card).V1 + card.value) + " %"
	if getTotalStrengthValues(card).V2 != 0:
		totalStrengthValues += " / " + str(getTotalStrengthValues(card).V2 + card.value2) + " %"
	if getTotalStrengthValues(card).V1 != 0:
		totalStrengthValues += ")"
	
	effectValue.text = currentStrengthValues + totalStrengthValues
	
	for stat in card.stats:
		var instance = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		statsContainer.add_child(instance)
		instance.setup(null, stat.amount, statIcons[stat.resource], true, false)
		
		var colors = [UtilsS.colorMissing, UtilsS.colorUncommon, UtilsS.colorLegendary, UtilsS.colorRare]
		instance.changeIconColor(colors[stat.resource])
		instance.changeFrameColor(colors[stat.resource])


func getTotalStrengthValues(_card: LevelUpCard):
	var strength1: float = 0
	var strength2: float = 0
	for card in playerScene.selectedCards:
		if card.type == _card.type:
			strength1 += card.value
			strength2 += card.value2
	
	return {"V1": strength1, "V2": strength2}


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


func gainModifiers():
	var value: float = card.value / 100
	var value2: float = card.value2 / 100
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
		Enums.cardType.CRITICAL_DAMAGE:
			playerScene.critDamageModifier += value
		Enums.cardType.DANGER:
			playerScene.healthModifier -= value
			playerScene.meleeDamageModifier -= value
			playerScene.rangedDamageModifier -= value
		
		
		Enums.cardType.MELEE_RANGED:
			playerScene.rangedDamageAfterMeleeAttack += value * 100
			playerScene.meleeDamageAfterRangedAttack += value * 100
		
		Enums.cardType.THIRD_ATTACK:
			playerScene.thirdAttackDamage += value * 100
		
		Enums.cardType.KNOCKBACK:
			playerScene.knockbackModifier += value
		
		Enums.cardType.PROJECTILE_SPREAD_SPEED:
			playerScene.projectileSpeedModifier += value
			playerScene.projectileSpreadModifier -= value2
		
		Enums.cardType.KILL_ATTACK_DELAY_SPEED:
			playerScene.attackDelayAfterKill -= value * 100
			playerScene.movementSpeedAfterKill += value2 * 100
		
		Enums.cardType.KILL_STAMINA:
			playerScene.staminaGainAfterKill += value * 100
		
		Enums.cardType.EXHAUSTING_ATTACK:
			playerScene.exhaustingDamageModifier += value
		
		Enums.cardType.SIGHT_RADIUS_ENTRY:
			playerScene.sightRadiusEntryEffect += value
		
		Enums.cardType.CONSUME_AMMO:
			playerScene.ammunitionConsumeModifier -= value
		
		Enums.cardType.DAMAGE_RANGE:
			playerScene.damageRangeMin -= value
			playerScene.damageRangeMax += value2
		
		Enums.cardType.EFFECT_DURATION:
			playerScene.effectDurationRandomModifier += value
		
		Enums.cardType.EFFECT_TAKEN_DURATION:
			playerScene.effectTakenStrengthModifier -= value
			playerScene.effectTakenDurationModifier -= value2
		
		Enums.cardType.CRIT_CHANCE:
			playerScene.critChance += value * 100
		
		Enums.cardType.CRIT_STAT_INCREASE:
			playerScene.critStatIncrease += value * 100


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


func _on_button_pressed():
	gainStats()
	gainModifiers()
	cardSelected.emit()
	playerScene.selectedCards.append(card)


func _on_button_mouse_entered():
	AnimationsS.slideUp(self, 25, 0.15)


func _on_button_mouse_exited():
	AnimationsS.slideDown(self, 0, 0.15)
