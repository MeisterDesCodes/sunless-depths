extends Node


class_name Utils


var colorBackground = Color("#161616")
var colorPrimary = Color("#E14F21")
var colorCommon = Color("#FFFFFF")
var colorUncommon = Color("#54A32F")
var colorRare = Color("#1E5F9B")
var colorEpic = Color("#4F2397")
var colorLegendary = Color("#D3A42B")
var colorMissing = Color("#B51111")
var colorBlack = Color("#000000")
var colorGrey = Color("#404040")
var colorTransparent = Color("#FFFFFF", 0)

var resourceDropSpeed: float = 150


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
	return randf_range(0.75 * value, 1.25 * value)


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


func applyStatusEffects(source: CharacterBody2D, target: CharacterBody2D, statusEffects: Array[StatusEffect]):
	for effect in statusEffects:
		if effect.appliesTo == Enums.statusEffectReceiver.SELF:
			applyStatusEffect(source, source, effect)
		if effect.appliesTo == Enums.statusEffectReceiver.TARGET:
			applyStatusEffect(source, target, effect)


func applyStatusEffect(source: CharacterBody2D, target: CharacterBody2D, _effect: StatusEffect):
	var entityEffect = getStatusEffect(target, _effect)
	if !_effect.isStackable && entityEffect:
		if entityEffect.remainingDuration < _effect.duration:
			entityEffect.remainingDuration = _effect.duration
		return
	
	var effect = _effect.duplicate()
	effect.strength *= source.effectStrengthModifier
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


func getStatutusEffectDescription(effect: StatusEffect):
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


func getStatusEffect(target: CharacterBody2D, _effect: StatusEffect):
	var effects = target.statusEffectComponent.statusEffects.filter(func(effect): return effect.effectType == _effect.effectType)
	return effects[0] if !effects.is_empty() else null
