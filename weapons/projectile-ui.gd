extends StaticBody2D


var hitEntities: Array
var direction: Vector2 = Vector2.ZERO

var caster: CharacterBody2D
var projectile: Projectile
var weapon = Weapon
var isPlayer: bool


func setup(_caster: CharacterBody2D, _projectile: Projectile, _position: Vector2, _direction: Vector2):
	caster = _caster
	projectile = _projectile
	global_position = _position
	direction = _direction
	look_at(position + direction)
	if caster.has_method("isPlayer"):
		weapon = caster.weaponInstance.weapon
		isPlayer = true
	else:
		isPlayer = false


func _physics_process(delta):
	var speed: float
	if isPlayer:
		speed = weapon.speedModifier * projectile.speed
	else:
		speed = projectile.speed
	global_position += direction * speed * delta


func _on_detection_area_area_entered(area):
	if !(area in hitEntities):
		hitEntities.append(area)
		var target = area.get_parent()
		if caster != target:
			var attack: Attack
			if isPlayer:
				attack = Attack.new(global_position, caster.entityResource, weapon.damageModifier * weapon.projectile.damage, weapon.knockbackModifier * weapon.projectile.knockback, Enums.weaponTypes.RANGED, weapon.projectile.statusEffects)
			else:
				attack = Attack.new(global_position, caster.entityResource, caster.currentAttack.damage, caster.currentAttack.knockback, Enums.weaponTypes.RANGED, caster.currentAttack.statusEffects)
			if projectile.isPiercing:
				attack.knockback = 0
			else:
				queue_free()
			target.processIncomingAttack(attack)


func _on_detection_area_body_entered(body):
	if body.has_method("isMap"):
		queue_free()
