extends State


class_name ProjectileState

@export var entity: CharacterBody2D

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var projectileSpawner = get_node("ProjectileSpawner")
@onready var projectileCooldown = get_node("ProjectileCooldown")
@onready var projectileTimer = get_node("ProjectileTimer")

func enter():
	entity.canLaunchProjectile = false
	var currentProjectile = entity.entityResource.attacks.filter(func(attack): return attack is EnemyRangedAttack).pick_random()
	
	projectileTimer.start()
	projectileCooldown.wait_time = UtilsS.getRandomRange(currentProjectile.attackDelay)
	projectileCooldown.start()
	
	projectileSpawner.spawnProjectiles(entity, currentProjectile.ammunition, entity.global_position, \
		entity.global_position.direction_to(playerScene.global_position), currentProjectile.spread, currentProjectile.amount)


func exit():
	projectileTimer.stop()


func update(delta):
	pass


func _on_projectile_cooldown_timeout():
	entity.canLaunchProjectile = true


func _on_projectile_timer_timeout():
	entity.changeToLastState()
