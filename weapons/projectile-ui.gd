extends StaticBody2D


@onready var projectileHitParticle: Node2D = get_node("ProjectileHitParticles")

var hitEntities: Array
var direction: Vector2 = Vector2.ZERO

var caster: CharacterBody2D
var enemyAttack: EnemyAttack
var projectile: InventoryAmmunition
var weapon: InventoryWeapon
var isPlayer: bool


func setup(_caster: CharacterBody2D, _projectile: InventoryAmmunition, _position: Vector2, _direction: Vector2):
	caster = _caster
	projectile = _projectile
	global_position = _position
	direction = _direction
	look_at(position + direction)
	if caster.has_method("isPlayer"):
		weapon = caster.weaponInstance.weapon
		isPlayer = true
	else:
		enemyAttack = caster.currentAttack
		isPlayer = false


func _physics_process(delta):
	var speed: float
	if isPlayer:
		speed = weapon.speedModifier * projectile.speed * caster.projectileSpeedModifier
	else:
		speed = projectile.speed * caster.projectileSpeedModifier
	global_position += direction * speed * delta


func _on_detection_area_area_entered(area):
	var target = area.get_parent()
	if (!isPlayer && target.has_method("isEnemy")):
		return
	
	if caster == target:
		return
	
	if area in hitEntities:
		return
		
	hitEntities.append(area)
	var attack: Attack
	if isPlayer:
		attack = Attack.new(global_position, caster, weapon.damageModifier * projectile.damage, weapon.knockbackModifier * projectile.knockback, Enums.weaponTypes.RANGED, projectile.statusEffects, UtilsS.checkForCrit(caster))
	else:
		attack = Attack.new(global_position, caster, enemyAttack.damage, enemyAttack.knockback, Enums.weaponTypes.RANGED, enemyAttack.statusEffects, UtilsS.checkForCrit(caster))
	if projectile.isPiercing:
		attack.knockback = 0
	else:
		queue_free()
	target.processIncomingAttack(attack)


func _on_detection_area_body_entered(body):
	if body.has_method("isMap") || body.get_parent().has_method("isMap"):
		UtilsS.playParticleEffect(projectileHitParticle)
		queue_free()
