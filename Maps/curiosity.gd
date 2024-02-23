extends Sprite2D



@onready var approachLabel = $"../CanvasLayer/UIControl/DialogApproachLabel"

@export var Dialog: Control

var playerInRange = false

var title = "Title"
var dialog = {"title": "Title", "description": "Description", "choices": ["Enter", "Leave"]}
var dialog2 = {"title": "Title2", "description": "Description2", "choices": ["1", "2"]}

func _ready():
	approachLabel.visible = false
	
	
func _process(delta):
	if Input.is_action_just_pressed("approach-curiosity") && playerInRange:
		Dialog.setupLocation(self)
		
		
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
	Dialog.pushDialog(dialog2)
	
	
	
	
	
func leave():
	Dialog.leave()
	approachLabel.visible = false
	

