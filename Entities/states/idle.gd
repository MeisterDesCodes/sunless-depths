extends State


class_name IdleState

@export var entity: CharacterBody2D

@onready var timer = $"IdleTimer"


func enter():
	timer.start()


func exit():
	timer.stop()


func update(delta):
	entity.moveToPath(entity.moveSpeed * 0.5)


func getDirection():
	var distance = entity.moveSpeed * 2
	var randX = randf_range(-distance, distance)
	var randY = randf_range(-distance, distance)
	var destination = Vector2(randX, randY)
	
	if entity.global_position.distance_to(destination + entity.global_position) < 100:
		destination *= 1.5
	destination += entity.global_position
	
	if (entity.navigationHandler):
		entity.navigationHandler.target_position = destination
	
	timer.wait_time = randf_range(3, 5)
	timer.start()


func randomModifier():
	return -1 if randi_range(0, 1) == 0 else 1


func _on_idle_timer_timeout():
	getDirection()
