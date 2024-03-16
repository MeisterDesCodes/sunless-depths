extends Node2D

signal showDialog

@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")
@onready var dialog = $"../../../CanvasLayer/UIControl/DialogUI"


var playerInRange = false

var title = "Title"
var dialog1 = {"title": "Title", "description": "Description", "choices": ["Enter", "Leave"]}
var dialog2 = {"title": "Title2", "description": "Description2", "choices": ["1", "2"]}

func _ready():
	approachLabel.visible = false
	
	
func _process(delta):
	if Input.is_action_just_pressed("approach-curiosity") && playerInRange:
		dialog.setupLocation(self)
		
		
func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		playerInRange = true
		approachLabel.visible = true
		approachLabel.text = "(R) to approach curiosity"


func _on_detection_radius_body_exited(body):
	playerInRange = false
	leave()


func selectChoice(choice):
	match choice:
		"enter":
			enter()
		"leave":
			leave()
	
func enter():
	dialog.pushDialog(dialog2)
	
	
	
func leave():
	approachLabel.visible = false
