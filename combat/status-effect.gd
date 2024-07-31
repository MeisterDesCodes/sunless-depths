extends Resource


class_name StatusEffect

@export var effectType: Enums.statusEffectType
@export var strength: float
@export var duration: float
@export var appliesTo: Enums.statusEffectReceiver
@export var isStackable: bool = true

var remainingDuration: float
var type = Enums.resourceType.STATUS_EFFECT


func onApply(entity: CharacterBody2D):
	var adjustedStrength: float = strength / 100
	match effectType:
		Enums.statusEffectType.AWARENESS:
			entity.visionRangeModifier += adjustedStrength
			entity.updateVisionRange()
		
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			entity.staminaCostModifier -= adjustedStrength
		Enums.statusEffectType.SLOWNESS:
			entity.movementSpeedModifier -= adjustedStrength


func onExpire(entity: CharacterBody2D):
	var adjustedStrength: float = strength / 100
	match effectType:
		Enums.statusEffectType.AWARENESS:
			entity.visionRangeModifier -= adjustedStrength
			entity.updateVisionRange()
		
		Enums.statusEffectType.STAMINA_COST_REDUCTION:
			entity.staminaCostModifier += adjustedStrength
		Enums.statusEffectType.SLOWNESS:
			entity.movementSpeedModifier += adjustedStrength


func onTick(entity: CharacterBody2D):
	var adjustedStrength: float = strength * entity.statusEffectComponent.statusEffectTimer.wait_time
	match effectType:
		Enums.statusEffectType.BLEED:
			entity.damageReceiver.receiveDamage(adjustedStrength, self)
		Enums.statusEffectType.POISON:
			entity.damageReceiver.receiveDamage(adjustedStrength, self)
		Enums.statusEffectType.BURN:
			entity.damageReceiver.receiveDamage(adjustedStrength, self)
		Enums.statusEffectType.HEAL:
			entity.damageReceiver.receiveHealing(adjustedStrength, self)
	
	remainingDuration -= entity.statusEffectComponent.statusEffectTimer.wait_time
	
	if entity.has_method("isPlayer"):
		entity.hudUI.updateStatusEffects()
	
	if remainingDuration <= 0:
		onExpire(entity)
		entity.statusEffectComponent.statusEffects.remove_at(entity.statusEffectComponent.statusEffects.find(self))
