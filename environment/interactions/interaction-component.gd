extends Node2D

signal onInteract

@export var interaction: Node2D
@export var triggersAutomatically: bool = false
@export var textDisplay: String = ""

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var resourceSpawner = get_node("ResourceSpawner")
@onready var particles = get_node("InteractionParticle")

var playerInRange = false
var completed = false
var approachLabel: Control  


func _ready():
	if triggersAutomatically:
		particles.queue_free()
	
	if interaction.lifetime == 0:
		deactivateInteraction()


func _process(delta):
	if Input.is_action_just_pressed("interact") && playerInRange && !completed && !playerScene.isInUIScene:
		interact(playerScene)
		if interaction.lifetime > 0:
			interaction.lifetime -= 1
			updateLabel()
			if interaction.lifetime == 0:
				deactivateInteraction()


func updateLabel():
	if textDisplay == "":
		textDisplay = "(E) to interact " + ("(" + str(interaction.lifetime) + " remaining)" if interaction.lifetime > 0 else "")
	approachLabel.setup(textDisplay)


func deactivateInteraction():
	completed = true
	particles.get_child(0).emitting = false
	if approachLabel:
		UILoaderS.closeUIOverlay(approachLabel)
		approachLabel = null


func _on_detection_radius_body_entered(body):
	if triggersAutomatically:
		if interaction.lifetime > 0:
			interact(playerScene)
			interaction.lifetime -= 1
		return
	
	if body.has_method("isPlayer") && !completed:
		approachLabel = UILoaderS.loadUIOverlay(preload("res://UI/shared/interaction-footer.tscn"))
		updateLabel()
		playerInRange = true


func interact(playerScene: CharacterBody2D):
	onInteract.emit(playerScene)


func _on_detection_radius_body_exited(body):
	if body.has_method("isPlayer"):
		playerInRange = false
		if approachLabel:
			UILoaderS.closeUIOverlay(approachLabel)


func dropResources(resources: Array[DropResource], speed: float, body: CharacterBody2D):
	var direction = global_position.direction_to(body.global_position)
	resourceSpawner.spawnResources(resources, Enums.resourceSpawnType.DASH, 
		global_position, direction, speed)
