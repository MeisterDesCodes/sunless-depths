extends Node2D


@export var entity: CharacterBody2D

@onready var hitParticles: Node2D = get_node("HitParticles")
@onready var effectParticles: Node2D = get_node("EffectParticles")
@onready var deathParticles: Node2D = get_node("DeathParticles")
@onready var dashParticles: Node2D = get_node("DashParticles")
@onready var desintegrateParticles: Node2D = get_node("DesintegrateParticles")


func update():
	var size: float = 1 + ((entity.entityResource.texture.get_width() - 400) / 400)
	effectParticles.scale = Vector2(size, size)


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


func activateHitParticles(position: Vector2):
	var color = UtilsS.colorPrimary
	UtilsS.playParticleEffect(hitParticles, 0, color)


func activateDeathParticles():
	UtilsS.playParticleEffect(deathParticles)


func activateDashParticles():
	var _rotation: float
	if entity.getDirection() != Vector2.ZERO:
		_rotation = entity.getDirection().angle()
	else:
		_rotation = entity.rotationPoint.rotation
	UtilsS.playParticleEffect(dashParticles, _rotation)


func activateDesintegrateParticles():
	var color = UtilsS.colorPrimaryTransparent
	UtilsS.playParticleEffect(desintegrateParticles, 0, color)


