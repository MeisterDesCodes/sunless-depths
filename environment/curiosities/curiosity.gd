extends Node2D


signal onEnter

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")

var approachLabel: Control
var playerInRange = false


func _process(delta):
	if Input.is_action_just_pressed("approach-curiosity") && playerInRange && playerScene.canAct():
		onEnter.emit()
		


func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		approachLabel = UILoaderS.loadUIOverlay(preload("res://UI/shared/interaction-footer.tscn"))
		approachLabel.setup("(R) to enter")
		playerInRange = true


func _on_detection_radius_body_exited(body):
	if body.has_method("isPlayer"):
		playerInRange = false
		if approachLabel:
			UILoaderS.closeUIOverlay(approachLabel)
