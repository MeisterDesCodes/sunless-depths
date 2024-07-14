extends Resource


class_name StatusEffect

@export var type: Enums.statusEffectType
@export var strength: float
@export var duration: float
@export var appliesTo: Enums.statusEffectReceiver


func onApply():
	pass


func onExpire():
	pass


func onTick(entity: CharacterBody2D):
	match type:
		Enums.statusEffectType.BLEED:
			entity.damageReceiver.receiveDamage(strength, self)
		Enums.statusEffectType.POISON:
			entity.damageReceiver.receiveDamage(strength, self)
		Enums.statusEffectType.BURN:
			entity.damageReceiver.receiveDamage(strength, self)
		Enums.statusEffectType.HEAL:
			entity.damageReceiver.receiveHealing(strength, self)
	
	duration -= entity.statusEffectComponent.statusEffectTimer.wait_time
	if duration <= 0:
		entity.statusEffectComponent.statusEffects.remove_at(entity.statusEffectComponent.statusEffects.find(self))
