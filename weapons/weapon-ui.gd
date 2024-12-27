extends Node2D


@export var entityScene: CharacterBody2D

@onready var animations = get_node("AnimationPlayer")
@onready var hitbox = get_node("StaticBody2D")
@onready var projectileSpawner = get_node("ProjectileSpawner")
@onready var sprite = get_node("Sprite2D")

var weapon: InventoryWeapon
var hitEntities: Array[CharacterBody2D]
var currentAnimationFrame = 0


func setup(_weapon: InventoryWeapon):
	weapon = _weapon
	sprite.texture = weapon.texture
	
	if weapon is MeleeWeapon:
		match weapon.meleeWeaponType:
			Enums.meleeWeaponType.DAGGER:
				sprite.position.y = -33
			Enums.meleeWeaponType.SWORD:
				sprite.position.y = -33
			Enums.meleeWeaponType.LANCE:
				sprite.position.y = -50
	else:
		sprite.position.y = -33
	
	for collision in hitbox.get_children():
		collision.disabled = true
	
	if weapon is MeleeWeapon:
		hitbox.get_children()[weapon.meleeWeaponType].disabled = false


func attack(attackDirection: Vector2):
	var animationIndex = currentAnimationFrame % weapon.animations.size()
	var animation = UtilsS.getEnumValue(Enums.weaponAttackType, weapon.animations[animationIndex])
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
	var consumeAmount: int = weapon.projectileAmount
	if randf() > entityScene.ammunitionConsumeModifier:
		consumeAmount = 0
	entityScene.inventory.removeResource(weapon.ammunition, consumeAmount)
	
	if animations.is_playing():
		animations.stop()
	animations.play(animation)
	
	var spawnPosition = global_position + Vector2(30, 5).rotated(attackDirection.angle())
	projectileSpawner.spawnProjectiles(entityScene, weapon.ammunition, spawnPosition, attackDirection, weapon.spread * entityScene.projectileSpreadModifier, weapon.projectileAmount)
	
	if entityScene.inventory.getResourceAmount(weapon.ammunition) == 0:
		weapon.ammunition = null
	
	entityScene.isAttacking = true
	await animations.animation_finished
	entityScene.isAttacking = false


func isWeapon():
	pass
