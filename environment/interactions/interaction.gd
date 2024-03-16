extends Node2D

signal entered

@export var sprite: Texture2D
@export var id: String

@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")
@onready var resourceSpawner = $"ResourceSpawner"


var player = null
var playerInRange = false


func _process(delta):
	if Input.is_action_just_pressed("interact") && playerInRange:
		entered.emit(player)


func _on_detection_radius_body_entered(body):
	if body.has_method("isPlayer"):
		player = body
		playerInRange = true
		approachLabel.visible = true
		approachLabel.text = "(E) to interact"
		
	
func _on_detection_radius_body_exited(body):
	playerInRange = false
	approachLabel.visible = false


func dropResources(resources: Array, min: int, max: int, speed: float, body: CharacterBody2D):
	var amount = randi_range(min, max)
	var direction = global_position.direction_to(body.global_position)
	resourceSpawner.spawnResources(resources.pick_random(), amount, Enums.resourceSpawnType.DASH, 
		global_position, direction, speed)
