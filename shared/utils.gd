extends Node


class_name Utils

var colorBackground = Color("#161616")
var colorPrimary = Color("#E14F21")
var colorPrimaryBright = Color("#E14F21")
var colorPrimaryTransparent = Color("#e5795b75")
var colorCommon = Color("#FFFFFF")
var colorUncommon = Color("#54A32F")
var colorRare = Color("#1E5F9B")
var colorEpic = Color("#4F2397")
var colorLegendary = Color("#D3A42B")
var colorMissing = Color("#B51111")
var colorBlack = Color("#000000")
var colorWhite = Color("#FFFFFF")
var colorDisabled = Color("#757575")
var colorGray = Color("#555555")
var colorTransparent = Color("#FFFFFF", 0)

var colorCanvasModulate = Color("#393939")

var resourceDropSpeed: float = 150

var randomRangeMin: float = 0.75
var randomRangeMax: float = 1.25

var shaderElements: Array


func updateResourceSlotTypes(slots: Array[InventorySlot]):
	for slot in slots:
		updateResourceType(slot.resource)


func updateResourceType(resource: InventoryResource):
	if resource == preload("res://inventory-resource/resources/material/primary/health.tres") || \
		resource == preload("res://inventory-resource/resources/material/primary/oxygen.tres"):
		resource.hidden = true
	
	if resource is InventoryMaterial:
		resource.type = Enums.resourceType.MATERIAL
	if resource is InventoryConsumable:
		resource.type = Enums.resourceType.CONSUMABLE
	if resource is InventoryBlueprint:
		resource.type = Enums.resourceType.BLUEPRINT
		resource.weight = 0.1
	if resource is InventoryWeapon:
		resource.type = Enums.resourceType.WEAPON
	if resource is InventoryEquipment:
		resource.type = Enums.resourceType.EQUIPMENT
	if resource is InventoryAmmunition:
		resource.type = Enums.resourceType.AMMUNITION
		resource.weight = 0.2
	if resource is InventoryCuriosity:
		resource.type = Enums.resourceType.CURIOSITY
		resource.weight = 0
	
	resource.filterType = resource.type



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
		var _strength = _effect.strength * source.effectStrengthModifier
		var _duration = _effect.duration * (1 + (randf() * (source.effectDurationRandomModifier - 1))) * target.effectTakenDurationModifier
		if entityEffect.strength <= _strength:
			if entityEffect.remainingDuration <= _duration:
				entityEffect.remainingDuration = _duration
				entityEffect.strength = _strength
		else:
			entityEffect.remainingDuration = _duration
			entityEffect.strength = _strength
		
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
	entityScene.soundComponent.onConsume()


func unequipResource(entityScene: CharacterBody2D, resource: InventoryResource):
	match resource.type:
		Enums.resourceType.EQUIPMENT:
			UtilsS.unequipItem(entityScene, resource, resource.equipmentType)
		Enums.resourceType.WEAPON:
			if resource in entityScene.equippedWeapons:
				equipWeapon(entityScene, resource, entityScene.equippedWeapons.find(resource))


func unequipItem(entityScene: CharacterBody2D, resource: InventoryResource, index: int):
	for modifier in resource.modifiers:
		modifyStat(entityScene, modifier, false)
	
	entityScene.equippedGear[index] = null
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func equipWeapon(entityScene: CharacterBody2D, resource: InventoryResource, index: int):
	if entityScene.equippedWeapons[index] == resource:
		if resource is RangedWeapon:
			entityScene.equippedWeapons[index].ammunition = null
		entityScene.equippedWeapons[index] = entityScene.fistWeapon
	else:
		var duplicateWeaponIndex = entityScene.equippedWeapons.find(resource)
		if duplicateWeaponIndex >= 0:
			entityScene.equippedWeapons[duplicateWeaponIndex] = entityScene.fistWeapon
		if index != duplicateWeaponIndex:
			if entityScene.equippedWeapons[index] is RangedWeapon:
				entityScene.equippedWeapons[index].ammunition = null
			entityScene.equippedWeapons[index] = resource
	
	entityScene.updateWeapons()


func equipItem(entityScene: CharacterBody2D, resource: InventoryResource, index: int):
	for modifier in resource.modifiers:
		modifyStat(entityScene, modifier, true)
	
	entityScene.equippedGear[index] = resource
	entityScene.setupLightSource()
	entityScene.updateMaxHealth()


func modifyStat(entityScene: CharacterBody2D, modifier: InventoryEquipmentModifier, isEquipped: bool):
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
		Enums.equipmentModifierType.LIGHT_RADIUS:
			entityScene.entityResource.lightRadius += value
		Enums.equipmentModifierType.OXYGEN_CAPACITY:
			entityScene.entityResource.oxygenCapacity += value
		Enums.equipmentModifierType.WEIGHT_CAPACITY:
			entityScene.entityResource.weightCapacity += value
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


func resourceCostArrayToString(array):
	var text: String = ""
	for element in array:
		text += str(element.amount) + " "
		text += pluralizeResource(element.resource, element.amount)
		if array.find(element) < array.size() - 1:
			text += ", "
	
	return text


func pluralizeResource(resource, amount):
	if amount > 1 && !resource.name.ends_with("s") && resource.rarity != Enums.resourceRarity.PRIMARY:
		return resource.name + "s"
	else:
		return resource.name


func round(value: float, decimals: int):
	return round(value * pow(10, decimals)) / pow(10, decimals)


func getStatusEffectDescription(effect: StatusEffect):
	match effect.effectType:
		Enums.statusEffectType.BLEED || Enums.statusEffectType.POISON || Enums.statusEffectType.BURN:
			return "Takes " + str(effect.strength) + " burn damage every second"
		Enums.statusEffectType.HEAL:
			return "Restores " + str(effect.strength) + " health every second"
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			return "Overall stamina costs are reduced by " + str(effect.strength) + " %"
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			return "Overall stamina costs are reduced by " + str(effect.strength) + " %"
		Enums.statusEffectType.SLOWNESS:
			return "Movement speed is reduced by " + str(effect.strength) + " %"
		Enums.statusEffectType.QUICK_FEET:
			return "Movement speed is increased by " + str(effect.strength) + " %"
		Enums.statusEffectType.HASTE:
			return "Attack delays are reduced by " + str(effect.strength * -1) + " %"
		Enums.statusEffectType.STAT_INCREASE:
			return "Overall stats are increased by " + str(effect.strength)
		Enums.statusEffectType.SATURATION:
			return "Restores " + str(effect.strength) + " % of nourishment every second"
		Enums.statusEffectType.STAMINA_RESTORE:
			return "Restores " + str(effect.strength) + " % of stamina every second"
		Enums.statusEffectType.ON_HIT:
			return "Attacks deal " + str(effect.strength) + " additional damage"
		Enums.statusEffectType.DAMAGE_INCREASE:
			return "Overall damage is increased by " + str(effect.strength)
		Enums.statusEffectType.MELEE_DAMAGE_INCREASE:
			return "Melee damage is increased by " + str(effect.strength)
		Enums.statusEffectType.RANGED_DAMAGE_INCREASE:
			return "Ranged damage is increased by " + str(effect.strength)
		Enums.statusEffectType.STARVATION:
			return "You are at the brink of starvation. \
				Damage and movement speed reduced by " + str(effect.strength)
		Enums.statusEffectType.SUFFOCATION:
			return "Without oxygen, you will quickly find your demise. \
				Vision and movement speed reduced by " + str(effect.strength)
	
	return ""


func getStatusEffectsByType(target: CharacterBody2D, _effect: StatusEffect):
	var effects = target.statusEffectComponent.statusEffects.filter(func(effect): return effect.effectType == _effect.effectType)
	return effects


func checkForCrit(critChance: float):
	return randf() <= critChance / 100


func playUIParticleEffect(particleComponent: Node2D, color: Color = UtilsS.colorWhite):
	var particle = particleComponent.get_child(0)
	particle.self_modulate = color
	if particle.emitting:
		particle.emitting = false
		particle.restart()
	else:
		particle.emitting = true


func playParticleEffect(particleComponent: Node2D, rotation: float = 0, color: Color = UtilsS.colorWhite):
	var particle = particleComponent.get_child(0).duplicate()
	particle.global_position = particleComponent.global_position
	particle.rotation = rotation
	particle.modulate = color
	get_tree().get_root().get_node("GameController/Game").particles.add_child(particle)
	particle.emitting = true
	
	await UtilsS.createTimer(particle.lifetime * 1.5)
	
	get_tree().get_root().get_node("GameController/Game").particles.remove_child(particle)


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
		
		Enums.cardType.CRIT_HEAL:
			entityScene.critHealChance += value * 100
		
		Enums.cardType.DASHING_DAMAGE:
			entityScene.dashingDamageModifier += value


func gainStats(entityScene: CharacterBody2D, card: LevelUpCard):
	for stat in card.stats:
		match stat.resource:
			Enums.statType.FEROCITY:
				entityScene.entityResource.ferocity += stat.amount
				entityScene.baseFerocity += stat.amount
			Enums.statType.PERSEVERANCE:
				entityScene.entityResource.perseverance += stat.amount
				entityScene.basePerseverance += stat.amount
			Enums.statType.AGILITY:
				entityScene.entityResource.agility += stat.amount
				entityScene.baseAgility += stat.amount
			Enums.statType.PERCEPTION:
				entityScene.entityResource.perception += stat.amount
				entityScene.basePerception += stat.amount

func playAnimation(animationPlayer: AnimationPlayer, animation: String):
	if animationPlayer.is_playing():
		animationPlayer.stop()
		animationPlayer.seek(0.0, true)
	animationPlayer.play(animation)


func getStatCheckChance(playerScene: CharacterBody2D, statCheck: StatCheck):
	if !statCheck:
		return 1
	
	var statValue: int = getValueFromStat(playerScene, statCheck)
	var chance: float = statCheck.baseChance + (1 - statCheck.baseChance) * (float(statValue) / float(statCheck.statMaximum))
	if chance > 1:
		chance = 1
	return chance


func getValueFromStat(playerScene: CharacterBody2D, statCheck: StatCheck):
	match statCheck.stat:
		Enums.equipmentModifierType.FEROCITY:
			return playerScene.entityResource.ferocity
		Enums.equipmentModifierType.PERSEVERANCE:
			return playerScene.entityResource.perseverance
		Enums.equipmentModifierType.AGILITY:
			return playerScene.entityResource.agility
		Enums.equipmentModifierType.PERCEPTION:
			return playerScene.entityResource.perception


func runShader(element, shader: String):
	var shaderMaterial = preload("res://assets/UI/shaders/dissolve-material-ui.tres").duplicate()
	#shaderMaterial.set_shader_parameter("dissolve_threshold", 1.25)
	element.material = shaderMaterial
	shaderElements.append(element)


func _process(delta):
	for shader in shaderElements:
		if is_instance_valid(shader):
			var amount: float = shader.material.get_shader_parameter("dissolve_threshold")
			shader.material.set_shader_parameter("dissolve_threshold", amount - 0.025)
		else:
			shaderElements.remove_at(shaderElements.find(shader))


func removeEntitiesFromScene(scene):
	for entity in scene.get_children():
		entity.queue_free()
		for element in entity.get_children():
			if element is Timer:
				element.queue_free()


func removeStatusEffects(entity: CharacterBody2D):
	for i in range(entity.statusEffectComponent.statusEffects.size() - 1, -1, -1):
		entity.statusEffectComponent.statusEffects[i].onExpire(entity)


func createTimer(duration: float):
	if get_tree():
		await UtilsS.get_tree().create_timer(duration).timeout
	return true
