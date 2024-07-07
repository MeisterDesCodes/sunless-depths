extends Node2D


signal onEnter

var approachLabel: Control

var playerInRange = false
var playerScene = null


func _process(delta):
	if Input.is_action_just_pressed("approach-curiosity") && playerInRange && playerScene.canAct():
		onEnter.emit()


func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		approachLabel = UILoaderS.loadUILabel(preload("res://UI/shared/dialog-approach.tscn"))
		playerInRange = true
		playerScene = body
		approachLabel.setup("(R) to approach curiosity")


func _on_detection_radius_body_exited(body):
	if body.has_method("isPlayer"):
		playerInRange = false
		playerScene = null
		approachLabel.queue_free()
