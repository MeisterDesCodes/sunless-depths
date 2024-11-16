extends State


class_name DashState

@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var dashTimer = get_node("DashTimer")
@onready var dashCooldown = get_node("DashCooldown")

var baseDashSpeed = 200
var dashSpeedModifier = 1.5
var direction: Vector2


func enter():
	UtilsS.playAnimation(entity.animations, "dashing")
	entity.canDash = false
	dashTimer.start()
	RandomNumberGenerator.new().randomize()
	dashCooldown.wait_time = UtilsS.getRandomRange(entity.currentAttack.attackDelay)
	dashCooldown.start()
	direction = entity.global_position.direction_to(playerScene.global_position).normalized()
	entity.velocity = Vector2.ZERO
	await get_tree().create_timer(0.15).timeout
	entity.isDashing = true
	entity.canDealContactDamage = true


func exit():
	dashTimer.stop()
	entity.navigationHandler.target_position = playerScene.global_position


func update(delta):
	entity.rotation = lerp_angle(entity.rotation, direction.normalized().angle(), 0.1)  
	if entity.isDashing:
		entity.velocity = lerp(entity.velocity, direction * (baseDashSpeed + entity.entityResource.moveSpeed * dashSpeedModifier), 0.25)
	else:
		entity.velocity = lerp(entity.velocity, Vector2.ZERO, 0.1)


func _on_dash_timer_timeout():
	entity.isDashing = false
	await get_tree().create_timer(0.25).timeout
	entity.canDealContactDamage = false
	await get_tree().create_timer(0.25).timeout
	entity.changeToLastState()


func _on_dash_cooldown_timeout():
	entity.canDash = true
