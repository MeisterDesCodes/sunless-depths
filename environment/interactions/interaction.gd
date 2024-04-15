extends Node2D

signal onEnter

@export var sprite: Texture2D
@export var id: String

@onready var resourceSpawner = get_node("ResourceSpawner")

var player = null
var playerInRange = false
var completed = false
var approachLabel: Control  


func _process(delta):
	if Input.is_action_just_pressed("interact") && playerInRange && !completed:
		onEnter.emit(player)


func _on_detection_radius_body_entered(body):
	approachLabel = UILoaderS.loadUIScene(preload("res://UI/other/dialog_approach.tscn"))
	if body.has_method("isPlayer") && !completed:
		player = body
		playerInRange = true
		approachLabel.setup("(E) to interact")


func _on_detection_radius_body_exited(body):
	playerInRange = false
	approachLabel.queue_free()


func dropResources(resources: Array[DropResource], speed: float, body: CharacterBody2D):
	var direction = global_position.direction_to(body.global_position)
	resourceSpawner.spawnResources(resources, Enums.resourceSpawnType.DASH, 
		global_position, direction, speed)
