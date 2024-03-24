extends CharacterBody2D


var player = null
var resource = null
var isMoving: bool = true
var canBePickedUp: bool = false
var moveSpeed: float = 0
var direction: Vector2 = Vector2.ZERO


func _physics_process(delta):
	if isMoving:
		velocity = direction * moveSpeed
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.1)
		
	move_and_slide()
	
	if canBePickedUp:
		var bodies = $"Area2D".get_overlapping_bodies()
		for body in bodies:
			player = body
			player.inventory.addResource(resource, 1)
			queue_free()


func setup(groundResource: InventoryResource):
	resource = groundResource
	$"Sprite2D".texture = resource.texture
	$"Shadow".texture = resource.texture

func _on_timer_timeout():
	isMoving = false


func _on_pickup_timer_timeout():
	canBePickedUp = true
