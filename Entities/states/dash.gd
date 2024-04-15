extends State


class_name DashState

@export var entity: CharacterBody2D

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var dashTimer = get_node("DashTimer")
@onready var dashCooldown = get_node("DashCooldown")

var dashSpeedModifier = 1.75
var direction: Vector2
var pause = true


func enter():
	entity.canDash = false
	entity.isDashing = true
	dashTimer.start()
	RandomNumberGenerator.new().randomize()
	dashCooldown.wait_time = UtilsS.generateRandomRange(entity.currentAttack.attackDelay)
	dashCooldown.start()
	direction = entity.global_position.direction_to(playerScene.global_position).normalized()
	entity.velocity = Vector2.ZERO
	await get_tree().create_timer(0.1).timeout
	pause = false


func exit():
	dashTimer.stop()
	pause = true
	entity.navigationHandler.target_position = playerScene.global_position


func update(delta):
	if !pause:
		entity.velocity = lerp(entity.velocity, direction * 300, 0.25)
	else:
		entity.look_at(playerScene.global_position)


func _on_dash_timer_timeout():
	entity.isDashing = false
	entity.changeToLastState()


func _on_dash_cooldown_timeout():
	entity.canDash = true
