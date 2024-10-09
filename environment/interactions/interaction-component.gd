extends Node2D

signal onInteract

@export var interaction: Node2D
@export var triggersAutomatically: bool = false

@onready var resourceSpawner = get_node("ResourceSpawner")
@onready var particles = get_node("InteractionParticle")

var player = null
var playerInRange = false
var completed = false
var approachLabel: Control  


func _ready():
	if triggersAutomatically:
		particles.queue_free()
	
	if interaction.lifetime == 0:
		deactivateInteraction()


func _process(delta):
	if Input.is_action_just_pressed("interact") && playerInRange && !completed && !player.isInUIScene:
		onInteract.emit(player)
		if interaction.lifetime > 0:
			interaction.lifetime -= 1
			if interaction.lifetime == 0:
				deactivateInteraction()


func deactivateInteraction():
	completed = true
	particles.get_child(0).emitting = false
	if approachLabel:
		UILoaderS.closeUILabel(approachLabel)
		approachLabel = null


func _on_detection_radius_body_entered(body):
	if triggersAutomatically:
		if interaction.lifetime > 0:
			onInteract.emit(player)
			interaction.lifetime -= 1
		return
	
	approachLabel = UILoaderS.loadUILabel(preload("res://UI/shared/dialog-approach.tscn"))
	if body.has_method("isPlayer") && !completed:
		player = body
		playerInRange = true
		approachLabel.setup("(E) to interact")


func _on_detection_radius_body_exited(body):
	playerInRange = false
	if approachLabel:
		UILoaderS.closeUILabel(approachLabel)


func dropResources(resources: Array[DropResource], speed: float, body: CharacterBody2D):
	var direction = global_position.direction_to(body.global_position)
	resourceSpawner.spawnResources(resources, Enums.resourceSpawnType.DASH, 
		global_position, direction, speed)
