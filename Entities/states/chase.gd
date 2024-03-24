extends State


class_name ChaseState

@onready var player = get_tree().get_root().get_node("Game/Entities/Player")

@export var entity: CharacterBody2D


func enter():
	$FollowTimer.start()


func exit():
	$FollowTimer.stop()


func update(delta):
	return
	entity.navigationHandler.target_position = player.global_position


func _on_follow_timer_timeout():
	entity.navigationHandler.target_position = player.global_position
