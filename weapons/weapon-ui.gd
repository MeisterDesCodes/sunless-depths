extends Marker2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var animations = get_node("AnimationPlayer")
@onready var hitbox = get_node("StaticBody2D/Area2D")
@onready var projectileSpawner = get_node("ProjectileSpawner")

var entityScene: CharacterBody2D
var weapon: InventoryWeapon
var hitEntities: Array
var currentAnimationFrame = 0


func setup(_entityScene: CharacterBody2D, _weapon: InventoryWeapon):
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
				var attack = Attack.new(global_position, entityScene, damage, knockback, Enums.weaponTypes.MELEE, weapon.statusEffects)
				area.get_parent().processIncomingAttack(attack)


func attack(attackDirection: Vector2):
	var animationIndex = currentAnimationFrame % weapon.animations.size()
	var animation = UtilsS.getEnumValue(Enums.weaponAttackType, weapon.animations[animationIndex]).to_upper()
	if weapon is MeleeWeapon:
		meleeAttack(animation)
	if weapon is RangedWeapon:
		rangedAttack(animation, attackDirection)
	currentAnimationFrame += 1


func meleeAttack(animationType: String):
	hitEntities = []
	if animations.is_playing():
		animations.stop()
	animations.play(animationType)
	entityScene.isAttacking = true
	await animations.animation_finished
	entityScene.isAttacking = false


func rangedAttack(animation: String, attackDirection: Vector2):
	playerScene.inventory.removeResource(weapon.ammunition, 1)
	
	if animations.is_playing():
		animations.stop()
	animations.play(animation)
	
	var spawnPosition = global_position + Vector2(30, 5).rotated(attackDirection.angle())
	projectileSpawner.spawnProjectiles(entityScene, weapon.ammunition, spawnPosition, attackDirection, weapon.spread, weapon.projectileAmount)
	
	if playerScene.inventory.getResourceAmount(weapon.ammunition) == 0:
		weapon.ammunition = null
	
	entityScene.isAttacking = true
	await animations.animation_finished
	entityScene.isAttacking = false


func isWeapon():
	pass
