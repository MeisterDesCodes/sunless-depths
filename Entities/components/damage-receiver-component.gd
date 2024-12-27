extends Node2D


@export var entity: CharacterBody2D

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var hitbox: Area2D = get_node("Hitbox")
@onready var collision: CollisionShape2D = get_node("Hitbox/CollisionShape2D")


func _ready():
	if entity.has_method("isPlayer"):
		hitbox.collision_mask = 160
	else:
		hitbox.collision_mask = 80
	
	await get_tree().process_frame
	
	collision.shape.radius = (entity.sprite.texture.get_size().x + \
		entity.sprite.texture.get_size().y) / 5 * entity.sprite.scale.x


func _process(delta):
	for body in hitbox.get_overlapping_bodies():
		var entityScene = body.get_parent().entityScene
		if entity.has_method("isPlayer"):
			if body.collision_layer == 32:
				handleEnemyContactDamage(entityScene)
			if body.collision_layer == 128:
				handleProjectile(entityScene, body, true)
		else:
			if body.collision_layer == 16:
				handleWeaponContactDamage(entityScene, body)
			if body.collision_layer == 64:
				handleProjectile(entityScene, body, false)


func handleEnemyContactDamage(entityScene: CharacterBody2D):
	if !entityScene.canDealContactDamage || entityScene.isDying:
		return
	
	var damage: float = entityScene.currentAttack.damage
	var knockback: float = entityScene.currentAttack.knockback
	var attack = Attack.new(entityScene.global_position, entityScene, damage, knockback, Enums.weaponTypes.MELEE, entityScene.currentAttack.statusEffects, false)
	
	if !entity.immunityFramesActive:
		receiveAttack(attack)
		entity.healthModified.emit()


func handleWeaponContactDamage(entityScene: CharacterBody2D, body: StaticBody2D):
	var weaponScene = body.get_parent()
	var weapon = weaponScene.weapon
	
	if entityScene.isAttacking && weapon is MeleeWeapon && !(entity in weaponScene.hitEntities):
		weaponScene.hitEntities.append(entity)
		var damage: float = weapon.damage * (1.25 * entityScene.dashingDamageModifier) if entityScene.isDashing else weapon.damage
		var knockback: float = weapon.knockback * 1.5 if entityScene.isDashing else weapon.knockback
		var attack = Attack.new(entityScene.global_position, entityScene, damage, knockback, Enums.weaponTypes.MELEE, weapon.statusEffects, UtilsS.checkForCrit(entityScene.critChance))
		entity.toggleAwareness()
		receiveAttack(attack)


func handleProjectile(entityScene: CharacterBody2D, body: StaticBody2D, isPlayer: bool):
	var projectileScene = body.get_parent()
	projectileScene.hitEntities.append(entity)
	
	var attack: Attack
	if isPlayer:
		attack = Attack.new(projectileScene.global_position, entityScene, projectileScene.projectile.damage, projectileScene.projectile.knockback, Enums.weaponTypes.RANGED, projectileScene.projectile.statusEffects, UtilsS.checkForCrit(projectileScene.critChance))
	else:
		attack = Attack.new(projectileScene.global_position, entityScene, projectileScene.weapon.damageModifier * projectileScene.projectile.damage, projectileScene.weapon.knockbackModifier * projectileScene.projectile.knockback, Enums.weaponTypes.RANGED, projectileScene.projectile.statusEffects, UtilsS.checkForCrit(projectileScene.critChance))
	
	if projectileScene.projectile.isPiercing:
		attack.knockback = 0
	else:
		projectileScene.queue_free()

	if !entity.immunityFramesActive:
		receiveAttack(attack)
		if isPlayer:
			entity.healthModified.emit()


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
		* damageModifier * damageTypeModifier * exhaustionModifier * critModifier * attack.caster.damageModifier \
		* entity.damageTakenModifier
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


func receiveHealing(amount: float, statusEffect: StatusEffect):
	if !canReceiveHealing():
		return
	
	var isCrit = randf() <= entity.critHealChance / 100
	if isCrit:
		amount *= (1.5 * entity.critDamageModifier)
	entity.health += amount
	showHealthChange(amount, false, isCrit, statusEffect)
	if entity.health >= entity.maxHealth:
		entity.health = entity.maxHealth


func receiveDamage(damage: float, isCrit: bool, statusEffect: StatusEffect):
	if entity.isDying:
		return
	
	entity.health -= damage
	showHealthChange(damage, true, isCrit, statusEffect)
	if entity.health <= 0 && !entity.isDying:
		entity.entityKilled()


func showHealthChange(amount: float, isDamage: bool, isCrit: bool, statusEffect):
	var spawnPosition: Vector2 = Vector2(global_position.x, global_position.y - 20)
	var damageIndicator = preload("res://entities/damage-indicator.tscn").instantiate()
	get_tree().get_root().add_child(damageIndicator)
	damageIndicator.setup(spawnPosition, amount, isDamage, statusEffect)
	
	if isDamage:
		damageIndicator.modulate = UtilsS.colorMissing
	if !isDamage:
		damageIndicator.modulate = UtilsS.colorUncommon
	if isCrit && isDamage:
		damageIndicator.modulate = UtilsS.colorLegendary
	if isCrit && !isDamage:
		damageIndicator.modulate = UtilsS.colorRare
	
	var percentage = amount / entity.maxHealth * 0.5
	var size = 0.5 + percentage
	if size > 1:
		size = 1
	damageIndicator.scale = Vector2(size, size)


func toggleKnockback(_position, knockback: float):
	entity.isKnockback = true
	entity.knockbackVector = global_position.direction_to(_position) * knockback * -1
	await UtilsS.createTimer(0.2)
	entity.isKnockback = false


func playHitAnimation(position: Vector2):
	UtilsS.playAnimation(entity.animations, "damage-received")
	entity.particleComponent.activateHitParticles(position)


func canReceiveHealing():
	return !entity.isDying && !entity.isSuffocating
