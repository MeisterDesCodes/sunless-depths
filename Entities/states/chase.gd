extends State


class_name ChaseState

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")

@export var entity: CharacterBody2D

@onready var timer = get_node("FollowTimer")


func enter():
	timer.start()


func exit():
	timer.stop()


func update(delta):
	entity.moveToPath(entity.moveSpeed, true)


func _on_follow_timer_timeout():
	entity.navigationHandler.target_position = playerScene.global_position
