extends Node2D


@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")


func receiveAttack(attack: Attack):
	entity.immunityFramesActive = true
	entity.immunityFramesTimer.start()
	playHitAnimation(attack.position)
	toggleKnockback(attack.position, attack.knockback * attack.caster.knockbackModifier)
	UtilsS.applyStatusEffects(attack.caster, entity, attack.statusEffects)
	entity.soundComponent.onHit(attack)
	
	var damageModifier: float = 1
	var damageTypeModifier: float = 1
	var difference: float = 0
	if attack.type == Enums.weaponTypes.MELEE:
		difference = UtilsS.calculateMeleeScaling(attack.caster.entityResource) - entity.entityResource.perseverance
		damageTypeModifier = attack.caster.meleeDamageModifier
		
		if attack.caster.rangedDamageAfterMeleeAttack != 0:
			UtilsS.applyStatusEffect(attack.caster, entity, UtilsS.setupEffect(preload("res://entities/resources/status-effects/ranged-attack-after-melee.tres"), \
				attack.caster.rangedDamageAfterMeleeAttack))
	else:
		difference = UtilsS.calculateRangedScaling(attack.caster.entityResource) - entity.entityResource.agility
		damageTypeModifier = attack.caster.rangedDamageModifier
		
		if attack.caster.meleeDamageAfterRangedAttack != 0:
			UtilsS.applyStatusEffect(attack.caster, entity, UtilsS.setupEffect(preload("res://entities/resources/status-effects/melee-attack-after-ranged.tres"), \
				attack.caster.rangedDamageAfterMeleeAttack))
	
	if difference > 0:
		damageModifier += difference * 0.05
	else:
		damageModifier += difference * 0.025
		
	if damageModifier < 0.3:
		damageModifier = 0.3
	
	var exhaustionModifier: float = 1
	if attack.caster.has_method("isPlayer") && attack.caster.hudUI.staminaBar.value <= 0:
		exhaustionModifier = attack.caster.exhaustingDamageModifier
	
	var critModifier: float = 1
	if attack.isCrit:
		critModifier = 1.5 * attack.caster.critDamageModifier
		
		if attack.caster.critStatIncrease != 0:
			UtilsS.applyStatusEffect(attack.caster, entity, UtilsS.setupEffect(preload("res://entities/resources/status-effects/crit-stat-increase.tres"), \
				attack.caster.critStatIncrease))
	
	var finalDamage = attack.damage * randf_range(attack.caster.damageRangeMin, attack.caster.damageRangeMax) \
		* damageModifier * damageTypeModifier * exhaustionModifier * critModifier * attack.caster.damageModifier
	receiveDamage(finalDamage, attack.isCrit, null)
	applyOnHitEffects(attack.caster, attack, finalDamage)


func applyOnHitEffects(attacker: CharacterBody2D, attack: Attack, damage: float):
	if attacker.has_method("isEnvironmentalObject"):
		return
	
	for effect in attacker.statusEffectComponent.statusEffects:
		if effect.effectApplyType == Enums.effectApplyType.HIT:
			effect.activateEffect(entity, attack, effect.strength * damage)
	
	attack.caster.attackCounter += 1
	if attack.caster.thirdAttackDamage != 0 && attack.caster.attackCounter % 3 == 0:
		UtilsS.applyStatusEffect(attack.caster, entity, UtilsS.setupEffect(preload("res://entities/resources/status-effects/damage-increase.tres"), \
			attack.caster.thirdAttackDamage))


func receiveHealing(amount: float, statusEffect):
	entity.health += amount
	showHealthChange(amount, false, false, statusEffect)
	if entity.health >= entity.maxHealth:
		entity.health = entity.maxHealth


func receiveDamage(damage: float, isCrit: bool, statusEffect):
	entity.health -= damage
	showHealthChange(damage, true, isCrit, statusEffect)
	if entity.health <= 0 && !entity.isDying:
		entity.entityKilled()


func showHealthChange(amount: float, isDamage: bool, isCrit: bool, statusEffect):
	var spawnPosition: Vector2 = Vector2(global_position.x, global_position.y - 20)
	var damageIndicator = preload("res://entities/damage-indicator.tscn").instantiate()
	get_tree().get_root().add_child(damageIndicator)
	damageIndicator.setup(spawnPosition, amount, isDamage, statusEffect)
	
	damageIndicator.modulate = UtilsS.colorUncommon
	if isDamage:
		damageIndicator.modulate = UtilsS.colorMissing
	if isCrit:
		damageIndicator.modulate = UtilsS.colorLegendary
	
	var percentage = amount / entity.maxHealth * 0.5
	var size = 0.5 + percentage
	if size > 1:
		size = 1
	damageIndicator.scale = Vector2(size, size)


func toggleKnockback(_position, knockback: float):
	entity.isKnockback = true
	entity.knockbackVector = global_position.direction_to(_position) * knockback * -1
	await get_tree().create_timer(0.2).timeout
	entity.isKnockback = false


func playHitAnimation(position: Vector2):
	if entity.animations.is_playing():
		entity.animations.stop()
	entity.animations.play("damage-received")
	entity.particleComponent.activateHitParticles(position)






