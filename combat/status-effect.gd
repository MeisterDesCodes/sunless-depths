extends Resource


class_name StatusEffect

@export var name: String
@export var strength: float
@export var duration: float


func apply(entity: CharacterBody2D):
	entity.damageReceiver.receiveDamage(strength)
	duration -= entity.statusEffectComponent.statusEffectTimer.wait_time
	if duration <= 0:
		entity.statusEffectComponent.statusEffects.remove_at(entity.statusEffectComponent.statusEffects.find(self))
