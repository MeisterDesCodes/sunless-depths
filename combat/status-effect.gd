extends Resource


class_name StatusEffect

@export var effectType: Enums.statusEffectType
@export var strength: float
@export var duration: float
@export var appliesTo: Enums.statusEffectReceiver
@export var isStackable: bool = true
@export var stackLimit: int = 0
@export var effectApplyType: Enums.effectApplyType

var remainingDuration: float
var maxRemainingDuration: float
var maxDuration: float
var accumulatedStrength: float
var type = Enums.resourceType.STATUS_EFFECT


func onApply(entity: CharacterBody2D):
	if effectApplyType == Enums.effectApplyType.APPLY:
		activateEffect(entity, null, strength)


func onTick(entity: CharacterBody2D):
	if effectApplyType == Enums.effectApplyType.TICK:
		activateEffect(entity, null, strength * entity.statusEffectComponent.statusEffectTimer.wait_time)
	
	remainingDuration -= entity.statusEffectComponent.statusEffectTimer.wait_time
	
	if entity.has_method("isPlayer"):
		entity.hudUI.updateStatusEffects()
	
	entity.particleComponent.activateEffectParticles(self)
	
	if remainingDuration <= 0:
		onExpire(entity)


func activateEffect(entity: CharacterBody2D, attack: Attack, strength: float):
	var percentageStrength: float = strength / 100
	match effectType:
		Enums.statusEffectType.AWARENESS:
			entity.visionRangeModifier += percentageStrength
			entity.updateVisionRange()
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			entity.staminaCostModifier -= percentageStrength
		Enums.statusEffectType.SLOWNESS:
			entity.movementSpeedModifier -= percentageStrength
		Enums.statusEffectType.QUICK_FEET:
			entity.movementSpeedModifier += percentageStrength
		Enums.statusEffectType.HASTE:
			entity.attackDelayModifier -= percentageStrength
		Enums.statusEffectType.STAT_INCREASE:
			entity.entityResource.ferocity += strength
			entity.entityResource.perseverance += strength
			entity.entityResource.agility += strength
			entity.entityResource.perception += strength
			entity.updateMaxHealth()
		
		Enums.statusEffectType.BLEED:
			entity.damageReceiver.receiveDamage(strength, false, self)
		Enums.statusEffectType.POISON:
			entity.damageReceiver.receiveDamage(strength, false, self)
		Enums.statusEffectType.BURN:
			entity.damageReceiver.receiveDamage(strength, false, self)
		Enums.statusEffectType.HEAL:
			entity.damageReceiver.receiveHealing(strength, self)
		Enums.statusEffectType.STAMINA_RESTORE:
			entity.currentStaminaRestore += strength
		Enums.statusEffectType.ON_HIT:
			entity.damageReceiver.receiveDamage(strength, false, self)
		Enums.statusEffectType.DAMAGE_INCREASE:
			entity.damageReceiver.receiveDamage(percentageStrength, false, self)
			onExpire(entity)
		Enums.statusEffectType.MELEE_DAMAGE_INCREASE:
			if attack.type == Enums.weaponTypes.MELEE:
				entity.damageReceiver.receiveDamage(percentageStrength, false, self)
				onExpire(entity)
		Enums.statusEffectType.RANGED_DAMAGE_INCREASE:
			if attack.type == Enums.weaponTypes.RANGED:
				entity.damageReceiver.receiveDamage(percentageStrength, false, self)
				onExpire(entity)


func onExpire(entity: CharacterBody2D):
	var percentageStrength: float = strength / 100
	match effectType:
		Enums.statusEffectType.AWARENESS:
			entity.visionRangeModifier -= percentageStrength
			entity.updateVisionRange()
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			entity.staminaCostModifier += percentageStrength
		Enums.statusEffectType.SLOWNESS:
			entity.movementSpeedModifier += percentageStrength
		Enums.statusEffectType.QUICK_FEET:
			entity.movementSpeedModifier -= percentageStrength
		Enums.statusEffectType.HASTE:
			entity.attackDelayModifier += percentageStrength
		Enums.statusEffectType.STAMINA_RESTORE:
			entity.currentStaminaRestore -= strength
		Enums.statusEffectType.STAT_INCREASE:
			entity.entityResource.ferocity -= strength
			entity.entityResource.perseverance -= strength
			entity.entityResource.agility -= strength
			entity.entityResource.perception -= strength
			entity.updateMaxHealth()
		
	remainingDuration = 0
	
	for effect in entity.statusEffectComponent.statusEffects:
		if effect.effectType == effectType:
			effect.accumulatedStrength -= strength
	
	if entity.has_method("isPlayer"):
		entity.hudUI.updateStatusEffects()
	entity.statusEffectComponent.statusEffects.remove_at(entity.statusEffectComponent.statusEffects.find(self))

	entity.particleComponent.deactivateEffectParticles()






