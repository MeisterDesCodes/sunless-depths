extends StaticBody2D

@onready var approachLabel = $"../CanvasLayer/UIControl/DialogApproachLabel"

var playerInRange = false

func _ready():
	approachLabel.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("interact") && playerInRange:
		print("Works")
		
		
func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		playerInRange = true
		approachLabel.visible = true
		approachLabel.text = "(E) to open chest"
		
	
func _on_detection_radius_body_exited(body):
	playerInRange = false
	approachLabel.visible = false
