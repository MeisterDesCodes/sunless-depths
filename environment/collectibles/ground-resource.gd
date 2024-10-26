extends CharacterBody2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var pickupRange = get_node("PickupRange")
@onready var detectionRange = get_node("DetectionRange")

var resource = null
var isMoving: bool = true
var canBePickedUp: bool = false
var moveSpeed: float = 0
var direction: Vector2 = Vector2.ZERO

var wasDropped: bool = false


func _physics_process(delta):
	if isMoving:
		velocity = direction * moveSpeed
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.1)
		
	move_and_slide()
	
	if canBePickedUp:
		for area in detectionRange.get_overlapping_areas():
			global_position += global_position.direction_to(playerScene.global_position) * 2
		
		for area in pickupRange.get_overlapping_areas():
			playerScene.inventory.addResource(resource, resource.pickupAmount)
			queue_free()


func setup(_resource: InventoryResource, _wasDropped: bool):
	resource = _resource
	wasDropped = _wasDropped
	$"Sprite2D".texture = resource.texture


func _on_timer_timeout():
	isMoving = false


func _on_pickup_timer_timeout():
	if !wasDropped:
		canBePickedUp = true


func _on_detection_range_area_exited(area):
	canBePickedUp = true
