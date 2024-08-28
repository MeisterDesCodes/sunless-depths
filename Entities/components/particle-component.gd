extends Node2D


@export var entity: CharacterBody2D

@onready var hitParticles: Node2D = get_node("HitParticles")
@onready var effectParticles: Node2D = get_node("EffectParticles")


func update():
	var size: float = 1 + ((entity.entityResource.texture.get_width() - 400) / 400)
	effectParticles.scale = Vector2(size, size)


func activateHitParticles(position: Vector2):
	hitParticles.get_child(0).restart()
	hitParticles.rotation = (entity.global_position.direction_to(position).rotated(-entity.rotation) * -1).angle()
	hitParticles.modulate = UtilsS.colorPrimary


func activateEffectParticles(effect: StatusEffect):
	match effect.effectType:
		Enums.statusEffectType.BLEED:
			effectParticles.modulate = UtilsS.colorMissing
		Enums.statusEffectType.POISON:
			effectParticles.modulate = UtilsS.colorMissing
		Enums.statusEffectType.BURN:
			effectParticles.modulate = UtilsS.colorMissing
		Enums.statusEffectType.SLOWNESS:
			effectParticles.modulate = UtilsS.colorPrimary
		Enums.statusEffectType.QUICK_FEET:
			effectParticles.modulate = UtilsS.colorLegendary
		Enums.statusEffectType.HEAL:
			effectParticles.modulate = UtilsS.colorUncommon
	
	var effects = [Enums.statusEffectType.BLEED, Enums.statusEffectType.POISON, Enums.statusEffectType.BURN, 
		Enums.statusEffectType.SLOWNESS, Enums.statusEffectType.QUICK_FEET,Enums.statusEffectType.HEAL]
	
	if effect.effectType in effects:
		effectParticles.get_child(0).emitting = true


func deactivateEffectParticles():
	effectParticles.get_child(0).emitting = false







