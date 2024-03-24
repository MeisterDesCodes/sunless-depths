extends Node2D


signal onEnter

@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")

var playerInRange = false
var player = null


func _ready():
	approachLabel.visible = false


func _process(delta):
	if Input.is_action_just_pressed("approach-curiosity") && playerInRange && !player.isInDialog:
		player.isInDialog = true
		onEnter.emit()


func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		playerInRange = true
		player = body
		approachLabel.visible = true
		approachLabel.text = "(R) to approach curiosity"


func _on_detection_radius_body_exited(body):
	playerInRange = false
	player = null
	approachLabel.visible = false
