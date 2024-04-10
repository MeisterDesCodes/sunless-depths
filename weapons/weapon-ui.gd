extends Marker2D


@onready var animations = get_node("AnimationPlayer")
@onready var hitbox = get_node("StaticBody2D/Area2D")
@onready var projectileSpawner = get_node("ProjectileSpawner")

var entityScene: CharacterBody2D
var weapon: Weapon
var hitEntities: Array
var currentAnimationFrame = 0


func setup(_entityScene: CharacterBody2D, _weapon: Weapon):
	entityScene = _entityScene
	weapon = _weapon
	$"StaticBody2D/Sprite2D".texture = weapon.texture


func _process(delta):
	if entityScene.isAttacking:
		var areas = hitbox.get_overlapping_areas()
		for area in areas:
			if weapon is MeleeWeapon && !(area in hitEntities):
				hitEntities.append(area)
				var damage: float = weapon.damage * 1.25 if entityScene.isDashing else weapon.damage
				var knockback: float = weapon.knockback * 1.5 if entityScene.isDashing else weapon.knockback
				var attack = Attack.new(global_position, entityScene.entityResource, damage, knockback, Enums.weaponTypes.MELEE, weapon.statusEffects)
				area.get_parent().processIncomingAttack(attack)


func attack(attackDirection: Vector2):
	var animationIndex = currentAnimationFrame % weapon.animations.size()
	var animation = Enums.weaponAttackType.keys()[weapon.animations[animationIndex]]
	if weapon is MeleeWeapon:
		meleeAttack(animation)
	if weapon is RangedWeapon:
		rangedAttack(animation, attackDirection, 3)
	currentAnimationFrame += 1


func meleeAttack(animationType: String):
	hitEntities = []
	if animations.is_playing():
		animations.stop()
	animations.play(animationType)
	entityScene.isAttacking = true
	await animations.animation_finished
	entityScene.isAttacking = false


func rangedAttack(animation: String, attackDirection: Vector2, projectileAmount: int):
	if animations.is_playing():
		animations.stop()
	animations.play(animation)
	
	var spawnPosition = global_position + Vector2(30, 5).rotated(attackDirection.angle())
	projectileSpawner.spawnProjectiles(entityScene, weapon.projectile, spawnPosition, attackDirection, weapon.spread, 3)
	
	entityScene.isAttacking = true
	await animations.animation_finished
	entityScene.isAttacking = false


func isWeapon():
	pass
