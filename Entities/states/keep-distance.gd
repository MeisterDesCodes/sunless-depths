extends State


class_name KeepDistanceState

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")

@export var entity: CharacterBody2D

@onready var distanceTimer = get_node("DistanceTimer")

var isKeepingDistance: bool


func enter():
	distanceTimer.start()


func exit():
	distanceTimer.stop()


func update(delta):
	entity.moveToPath(entity.moveSpeed * 0.75 if isKeepingDistance else entity.moveSpeed, !isKeepingDistance)


func _on_distance_timer_timeout():
	var distance: float = entity.global_position.distance_to(playerScene.global_position)
	var keepDistanceThreshold: float = entity.baseVisionRange * 0.7
	var chaseThreshold: float = entity.baseVisionRange * 0.9
	if distance <= keepDistanceThreshold:
		isKeepingDistance = true
		var direction: Vector2 = playerScene.global_position.direction_to(entity.global_position)
		var movePosition: Vector2 = entity.global_position + direction * entity.entityResource.moveSpeed * 5
		entity.navigationHandler.target_position = movePosition
	
	if distance > keepDistanceThreshold && distance < chaseThreshold:
		entity.navigationHandler.target_position = entity.global_position
	
	if distance >= chaseThreshold:
		isKeepingDistance = false
		entity.navigationHandler.target_position = playerScene.global_position
