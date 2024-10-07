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

var colorCanvasModulate = Color("#292929")

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


func useConsumable(entityScene: CharacterBody2D, consumable: InventoryConsumable):
	applyStatusEffects(entityScene, entityScene, consumable.statusEffects)
	consumable.remainingCooldown = consumable.cooldown
	entityScene.inventory.removeResource(consumable, 1)
	if entityScene.inventory.getResourceAmount(consumable) <= 0:
		entityScene.equippedConsumable = null
	entityScene.hudUI.updateConsumable()


func unequipItem(entityScene, item, index):
	for modifier in item.modifiers:
		modifyStat(entityScene, modifier, false)
	
	entityScene.equippedGear[index] = null
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func equipItem(entityScene, item, index):
	for modifier in item.modifiers:
		modifyStat(entityScene, modifier, true)
	
	entityScene.equippedGear[index] = item
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func modifyStat(entityScene, modifier: InventoryEquipmentModifier, isEquipped: bool):
	var value: float = modifier.value
	if !isEquipped:
		value = value * -1
	var adjustedValue: float = value / 100
	
	match modifier.type:
		Enums.equipmentModifierType.FEROCITY:
			entityScene.entityResource.ferocity += value
		Enums.equipmentModifierType.PERSEVERANCE:
			entityScene.entityResource.perseverance += value
		Enums.equipmentModifierType.AGILITY:
			entityScene.entityResource.agility += value
		Enums.equipmentModifierType.PERCEPTION:
			entityScene.entityResource.perception += value
		Enums.equipmentModifierType.OXYGEN_CAPACITY:
			entityScene.entityResource.oxygenCapacity += value
		Enums.equipmentModifierType.LIGHT_RADIUS:
			entityScene.entityResource.lightRadius += value
		Enums.equipmentModifierType.MAX_HEALTH:
			entityScene.maxHealth += value
		Enums.equipmentModifierType.DAMAGE:
			entityScene.damageModifier += adjustedValue


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


func playParticleEffect(particleComponent: Node2D, rotation: float = 0, color: Color = UtilsS.colorWhite, isLocal: bool = false):
	var particle = particleComponent.get_child(0).duplicate()
	if isLocal:
		particle.position = particleComponent.position
	else:
		particle.global_position = particleComponent.global_position
	particle.rotation = rotation
	particle.modulate = color
	get_tree().get_root().get_node("Game").particles.add_child(particle)
	particle.emitting = true
	
	await get_tree().create_timer(particle.lifetime * 1.5).timeout
	
	get_tree().get_root().get_node("Game").particles.remove_child(particle)


func equipCard(entityScene: CharacterBody2D, card: LevelUpCard):
	gainStats(entityScene, card)
	gainModifiers(entityScene, card)


func gainModifiers(entityScene: CharacterBody2D, card: LevelUpCard):
	var value: float = card.value / 100
	var value2: float = card.value2 / 100
	match card.type:
		Enums.cardType.MELEE_DAMAGE:
			entityScene.meleeDamageModifier += value
		Enums.cardType.RANGED_DAMAGE:
			entityScene.rangedDamageModifier += value
		Enums.cardType.ATTACK_DELAY:
			entityScene.attackDelayModifier -= value
		Enums.cardType.HEALTH:
			entityScene.healthModifier += value
		Enums.cardType.MOVEMENT_SPEED:
			entityScene.movementSpeedModifier += value
		Enums.cardType.SIGHT:
			entityScene.sightRadiusModifier += value
		Enums.cardType.FORTUNE:
			entityScene.lootModifier += value
		Enums.cardType.EFFECT_STRENGTH:
			entityScene.effectStrengthModifier += value
		Enums.cardType.STAMINA_COST:
			entityScene.staminaCostModifier -= value
		Enums.cardType.CRITICAL_DAMAGE:
			entityScene.critDamageModifier += value
		Enums.cardType.DANGER:
			entityScene.healthModifier -= value
			entityScene.meleeDamageModifier -= value
			entityScene.rangedDamageModifier -= value
		
		
		Enums.cardType.MELEE_RANGED:
			entityScene.rangedDamageAfterMeleeAttack += value * 100
			entityScene.meleeDamageAfterRangedAttack += value * 100
		
		Enums.cardType.THIRD_ATTACK:
			entityScene.thirdAttackDamage += value * 100
		
		Enums.cardType.KNOCKBACK:
			entityScene.knockbackModifier += value
		
		Enums.cardType.PROJECTILE_SPREAD_SPEED:
			entityScene.projectileSpeedModifier += value
			entityScene.projectileSpreadModifier -= value2
		
		Enums.cardType.KILL_ATTACK_DELAY_SPEED:
			entityScene.attackDelayAfterKill -= value * 100
			entityScene.movementSpeedAfterKill += value2 * 100
		
		Enums.cardType.KILL_STAMINA:
			entityScene.staminaGainAfterKill += value * 100
		
		Enums.cardType.EXHAUSTING_ATTACK:
			entityScene.exhaustingDamageModifier += value
		
		Enums.cardType.SIGHT_RADIUS_ENTRY:
			entityScene.sightRadiusEntryEffect += value
		
		Enums.cardType.CONSUME_AMMO:
			entityScene.ammunitionConsumeModifier -= value
		
		Enums.cardType.DAMAGE_RANGE:
			entityScene.damageRangeMin -= value
			entityScene.damageRangeMax += value2
		
		Enums.cardType.EFFECT_DURATION:
			entityScene.effectDurationRandomModifier += value
		
		Enums.cardType.EFFECT_TAKEN_DURATION:
			entityScene.effectTakenStrengthModifier -= value
			entityScene.effectTakenDurationModifier -= value2
		
		Enums.cardType.CRIT_CHANCE:
			entityScene.critChance += value * 100
		
		Enums.cardType.CRIT_STAT_INCREASE:
			entityScene.critStatIncrease += value * 100


func gainStats(entityScene: CharacterBody2D, card: LevelUpCard):
	for stat in card.stats:
		match stat.resource:
			Enums.statType.FEROCITY:
				entityScene.entityResource.ferocity += stat.amount
			Enums.statType.PERSEVERANCE:
				entityScene.entityResource.perseverance += stat.amount
			Enums.statType.AGILITY:
				entityScene.entityResource.agility += stat.amount
			Enums.statType.PERCEPTION:
				entityScene.entityResource.perception += stat.amount




