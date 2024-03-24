extends State


class_name IdleState

@export var entity: CharacterBody2D

@onready var timer = $"IdleTimer"


func enter():
	timer.start()


func exit():
	pass


func update(delta):
	pass


func getDirection():
	var distance = entity.moveSpeed * 1.5
	var randX = randf_range(distance, distance * 2) * randomModifier()
	var randY = randf_range(distance, distance * 2) * randomModifier()
	var position = Vector2(randX, randY) + entity.global_position
	if (entity.navigationHandler):
		entity.navigationHandler.target_position = position
	
	timer.wait_time = randf_range(4, 6)
	timer.start()


func randomModifier():
	return -1 if randi_range(0, 1) == 0 else 1


func _on_idle_timer_timeout():
	getDirection()
