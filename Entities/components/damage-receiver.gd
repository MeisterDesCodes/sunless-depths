extends Node2D


@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")


func receiveAttack(attack: Attack):
	entity.immunityFramesActive = true
	entity.immunityFramesTimer.start()
	playHitAnimation(attack.position)
	toggleKnockback(attack.position, attack.knockback)
	UtilsS.applyStatusEffects(attack.caster, entity, attack.statusEffects)
	
	var damageModifier = 1
	var damageTypeModifier: float
	var difference: float
	if attack.type == Enums.weaponTypes.MELEE:
		difference = UtilsS.calculateMeleeScaling(attack.caster.entityResource) - entity.entityResource.perseverance
		damageTypeModifier = attack.caster.meleeDamageModifier
	else:
		difference = UtilsS.calculateRangedScaling(attack.caster.entityResource) - entity.entityResource.agility
		damageTypeModifier = attack.caster.rangedDamageModifier
	
	if difference > 0:
		damageModifier += difference * 0.05
	else:
		damageModifier += difference * 0.025
		
	if damageModifier < 0.3:
		damageModifier = 0.3
	
	var finalDamage = attack.damage * randf_range(0.75, 1.25) * damageModifier * damageTypeModifier
	receiveDamage(finalDamage, null)


func receiveHealing(amount: float, statusEffect):
	entity.health += amount
	showHealthChange(amount, false, statusEffect)
	if entity.health >= entity.entityResource.maxHealth:
		entity.health = entity.entityResource.maxHealth


func receiveDamage(damage, statusEffect):
	entity.health -= damage
	showHealthChange(damage, true, statusEffect)
	if entity.health <= 0 && !entity.isDying:
		entity.entityKilled()


func showHealthChange(amount: float, isDamage: bool, statusEffect):
	var damageIndicator = preload("res://entities/damage-indicator.tscn").instantiate()
	if isDamage:
		damageIndicator.modulate = UtilsS.colorMissing
	else:
		damageIndicator.modulate = UtilsS.colorUncommon
	
	var percentage = amount / entity.entityResource.maxHealth * 0.5
	var size = 0.75 + percentage
	if size > 1.25:
		size = 1.25
	damageIndicator.scale = Vector2(size, size)
	get_tree().get_root().add_child(damageIndicator)
	damageIndicator.setup(global_position, amount, isDamage, statusEffect)


func toggleKnockback(_position, knockback: float):
	entity.isKnockback = true
	entity.knockbackVector = global_position.direction_to(_position) * knockback * -1
	await get_tree().create_timer(0.2).timeout
	entity.isKnockback = false


func playHitAnimation(_position: Vector2):
	if entity.animations.is_playing():
		entity.animations.stop()
	entity.animations.play("damage-received")
	
	if entity.has_method("isEnemy"):
		entity.hitParticles.restart()
		entity.hitParticles.direction = entity.global_position.direction_to(_position).rotated(-rotation) * -1
		if entity.health < entity.maxHealth / 2:
			entity.bloodParticles.emitting = true
			entity.bloodParticles.amount = (entity.maxHealth / 2 - entity.health) / entity.maxHealth / 2 * 200






