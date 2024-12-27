extends Node2D


@onready var staticBody: StaticBody2D = get_node("StaticBody2D")
@onready var collision: CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var projectileHitParticle: Node2D = get_node("ProjectileHitParticles")

var hitEntities: Array
var direction: Vector2 = Vector2.ZERO

var entityScene: CharacterBody2D
var projectileSpeedModifier: float
var critChance: float
var projectile: InventoryAmmunition
var weapon: InventoryWeapon
var isPlayer: bool


func setup(_caster: CharacterBody2D, _projectile: InventoryAmmunition, _position: Vector2, _direction: Vector2):
	entityScene = _caster
	projectileSpeedModifier = entityScene.projectileSpeedModifier
	critChance = entityScene.critChance
	projectile = _projectile
	global_position = _position
	direction = _direction
	look_at(position + direction)
	staticBody.collision_layer = 64 if entityScene.has_method("isPlayer") else 128
	
	if projectile.texture:
		sprite.texture = projectile.texture
	collision.shape.size.x = sprite.texture.get_size().x / 2 * sprite.scale.x
	collision.shape.size.y = sprite.texture.get_size().y / 2 * sprite.scale.y
	
	if entityScene.has_method("isPlayer"):
		weapon = entityScene.weaponInstance.weapon
		isPlayer = true
	else:
		isPlayer = false


func _physics_process(delta):
	var speed: float
	if isPlayer:
		speed = weapon.speedModifier * projectile.speed * projectileSpeedModifier
	else:
		speed = projectile.speed * projectileSpeedModifier
	global_position += direction * speed * delta


func _on_hitbox_body_entered(body):
	UtilsS.playParticleEffect(projectileHitParticle)
	queue_free()
