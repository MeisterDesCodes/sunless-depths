extends Node


class_name Utils


var colorBackground = Color("#161616")
var colorPrimary = Color("#E14F21")
var colorPrimaryBright = Color("#FF794E")
var colorCommon = Color("#FFFFFF")
var colorUncommon = Color("#54A32F")
var colorRare = Color("#1E5F9B")
var colorEpic = Color("#4F2397")
var colorLegendary = Color("#D3A42B")
var colorMissing = Color("#B51111")
var colorBlack = Color("#000000")
var colorWhite = Color("#FFFFFF")
var colorDisabled = Color("#959595")
var colorTransparent = Color("#FFFFFF", 0)

var colorCanvasModulate = Color("#040404")

var resourceDropSpeed: float = 150

var randomRangeMin: float = 0.75
var randomRangeMax: float = 1.25


func updateResourceType(resource: InventoryResource):
	if resource is InventoryMaterial:
		resource.type = Enums.resourceType.MATERIAL
	if resource is InventoryConsumable:
		resource.type = Enums.resourceType.CONSUMABLE
	if resource is InventoryBlueprint:
		resource.type = Enums.resourceType.BLUEPRINT
	if resource is InventoryWeapon:
		resource.type = Enums.resourceType.WEAPON
	if resource is InventoryEquipment:
		resource.type = Enums.resourceType.EQUIPMENT
	if resource is InventoryAmmunition:
		resource.type = Enums.resourceType.AMMUNITION


func getScalingValue(value: float):
	return 100 / (value + 100)


func getRandomRange(value: float):
	return randf_range(randomRangeMin * value, randomRangeMax * value)


func getEnumValue(_enum, _key):
	var text: String
	var enumValue = _enum.keys()[_key].to_lower()
	var array = enumValue.split("_")
	for value in array:
		text += value[0].to_upper() + value.substr(1,-1) + " "
	text = text.left(text.length() - 1)
	
	return text


func getRarityColor(rarity: Enums.resourceRarity):
	match rarity:
		Enums.resourceRarity.PRIMARY:
			return UtilsS.colorPrimary
		Enums.resourceRarity.COMMON:
			return UtilsS.colorCommon
		Enums.resourceRarity.UNCOMMON:
			return UtilsS.colorUncommon
		Enums.resourceRarity.RARE:
			return UtilsS.colorRare
		Enums.resourceRarity.EPIC:
			return UtilsS.colorEpic
		Enums.resourceRarity.LEGENDARY:
			return UtilsS.colorLegendary


func calculateMeleeScaling(attacker: Entity):
	return attacker.ferocity + attacker.agility * 0.5


func calculateRangedScaling(attacker: Entity):
	return attacker.agility * 0.5 + attacker.perception * 0.5


func setupEffect(_effect: StatusEffect, strength: float):
	var effect = _effect.duplicate()
	effect.strength = strength
	return effect


func applyStatusEffects(source: CharacterBody2D, target: CharacterBody2D, statusEffects: Array[StatusEffect]):
	for effect in statusEffects:
		applyStatusEffect(source, target, effect)


func applyStatusEffect(source: CharacterBody2D, target: CharacterBody2D, _effect: StatusEffect):
	if _effect.appliesTo == Enums.statusEffectReceiver.SELF:
		target = source
	
	var entityEffects = getStatusEffectsByType(target, _effect)
	if !_effect.isStackable && !entityEffects.is_empty():
		var entityEffect = entityEffects[0]
		if entityEffect.remainingDuration <= _effect.duration && entityEffect.strength <= _effect.strength:
			entityEffect.remainingDuration = _effect.duration
			entityEffect.strength = _effect.strength
		return
	
	if _effect.stackLimit > 0 && _effect.stackLimit <= entityEffects.size():
		return
	
	var effect = _effect.duplicate()
	effect.strength *= source.effectStrengthModifier * target.effectTakenStrengthModifier
	effect.duration *= (1 + (randf() * (source.effectDurationRandomModifier - 1))) * target.effectTakenDurationModifier
	effect.accumulatedStrength = effect.strength
	effect.remainingDuration = effect.duration
	target.statusEffectComponent.statusEffects.append(effect)
	effect.onApply(target)
	if target.has_method("isPlayer"):
		target.hudUI.addStatusEffect(effect)


func unequipItem(entityScene, item, index):
	entityScene.entityResource.ferocity -= item.ferocityModifier
	entityScene.entityResource.perseverance -= item.perseveranceModifier
	entityScene.entityResource.agility -= item.agilityModifier
	entityScene.entityResource.perception -= item.perceptionModifier
	entityScene.entityResource.lightRadius -= item.lightRadius
	entityScene.entityResource.oxygenCapacity -= item.oxygenCapacity
	entityScene.equippedGear[index] = null
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func equipItem(entityScene, item, index):
	entityScene.entityResource.ferocity += item.ferocityModifier
	entityScene.entityResource.perseverance += item.perseveranceModifier
	entityScene.entityResource.agility += item.agilityModifier
	entityScene.entityResource.perception += item.perceptionModifier
	entityScene.entityResource.lightRadius += item.lightRadius
	entityScene.entityResource.oxygenCapacity += item.oxygenCapacity
	entityScene.equippedGear[index] = item
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func enumArrayToString(_enum, array):
	var text: String = ""
	for element in array:
		text += getEnumValue(_enum, element)
		if array.find(element) < array.size() - 1:
			text += ", "
	
	return text


func resourceNameArrayToString(array):
	var text: String = ""
	for element in array:
		text += element.resource.name
		if array.find(element) < array.size() - 1:
			text += ", "
	
	return text


func round(value: float, decimals: int):
	return round(value * pow(10, decimals)) / pow(10, decimals)


func getStatusEffectDescription(effect: StatusEffect):
	match effect.effectType:
		Enums.statusEffectType.BLEED:
			return "Takes " + str(effect.strength) + " bleed damage every second"
		Enums.statusEffectType.POISON:
			return "Takes " + str(effect.strength) + " poison damage every second"
		Enums.statusEffectType.BLEED:
			return "Takes " + str(effect.strength) + " burn damage every second"
		Enums.statusEffectType.HEAL:
			return "Restores " + str(effect.strength) + " health every second"
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			return "Overall stamina costs are reduced by " + str(effect.strength) + " %"
	return ""


func getStatusEffectsByType(target: CharacterBody2D, _effect: StatusEffect):
	var effects = target.statusEffectComponent.statusEffects.filter(func(effect): return effect.effectType == _effect.effectType)
	return effects


func checkForCrit(entity: CharacterBody2D):
	var isCrit: bool = false
	if randf() <= entity.critChance / 100:
		isCrit = true
	
	return isCrit










