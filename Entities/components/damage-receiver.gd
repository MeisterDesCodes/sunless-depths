extends Node2D


@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")


func receiveAttack(attack: Attack):
	entity.immunityFramesActive = true
	entity.immunityFramesTimer.start()
	playHitAnimation(attack.position)
	toggleKnockback(attack.position, attack.knockback)
	applyStatusEffects(attack.statusEffects)
	
	var attacker = attack.caster
	var damageModifier = 1
	var difference
	if attack.type == Enums.weaponTypes.MELEE:
		difference = attacker.ferocity - entity.entityResource.perseverance
	else:
		difference = attacker.ferocity * 0.5 + attacker.perception * 0.5 - entity.entityResource.agility
	
	if difference > 0:
		damageModifier += difference * 0.05
	else:
		damageModifier += difference * 0.025
		
	if damageModifier < 0.3:
		damageModifier = 0.3
	
	var finalDamage = attack.damage * randf_range(0.75, 1.25) * damageModifier
	receiveDamage(finalDamage)


func receiveDamage(damage):
	entity.health -= damage
	showDamage(damage)
	if entity.health <= 0:
		entity.entityKilled()


func showDamage(damage: float):
	var damageIndicator = preload("res://entities/damage-indicator.tscn").instantiate()
	if entity.has_method("isPlayer"):
		damageIndicator.modulate = UtilsS.colorMissing
	else:
		damageIndicator.modulate = UtilsS.colorUncommon
	
	var size = damage / entity.entityResource.maxHealth * 10
	if size < 0.75:
		size = 0.75
	if size > 1.25:
		size = 1.25
	damageIndicator.scale = Vector2(size, size)
	get_tree().get_root().add_child(damageIndicator)
	damageIndicator.setup(global_position, damage)


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
			entity.bloodParticles.visible = true
			entity.bloodParticles.amount = (entity.maxHealth / 2 - entity.health) / entity.maxHealth / 2 * 200


func applyStatusEffects(statusEffects: Array[StatusEffect]):
	for effect in statusEffects:
		entity.statusEffectComponent.statusEffects.append(effect.duplicate())






