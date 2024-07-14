@tool
extends Node2D


@export var closedTexture: Texture2D:
	set(value):
		closedTexture = value
		$"Sprite2D".texture = closedTexture

@export var openedTexture: Texture2D
@export var resources: Array[DropResource]
@export var lifetime: int

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)
	$"Sprite2D".texture = closedTexture


func interact(body):
	$"Sprite2D".texture = openedTexture
	if openedTexture.get_size().y > closedTexture.get_size().y:
		global_position -= Vector2(0, 10).rotated(deg_to_rad(get_rotation_degrees()))
	interaction.dropResources(resources, UtilsS.resourceDropSpeed, body)





