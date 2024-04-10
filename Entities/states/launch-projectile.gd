extends State


class_name ProjectileState

@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var projectileSpawner = get_node("ProjectileSpawner")
@onready var projectileCooldown = get_node("ProjectileCooldown")
@onready var projectileTimer = get_node("ProjectileTimer")

func enter():
	projectileTimer.start()
	projectileCooldown.wait_time = randf_range(2, 3)
	projectileCooldown.start()
	entity.canLaunchProjectile = false
	projectileSpawner.spawnProjectiles(entity, entity.currentAttack.projectile, entity.global_position, entity.global_position.direction_to(playerScene.global_position), 20, 5)


func exit():
	projectileTimer.stop()


func update(delta):
	pass


func _on_projectile_cooldown_timeout():
	entity.canLaunchProjectile = true


func _on_projectile_timer_timeout():
	entity.changeToNormalState()