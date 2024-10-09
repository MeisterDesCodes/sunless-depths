@tool
extends Node2D


@export var closedTexture: Texture2D:
	set(value):
		closedTexture = value
		$"Sprite2D".texture = closedTexture

@export var openedTexture: Texture2D
@export var resources: Array[DropResource]
@export var lifetime: int
@export var type: Enums.chestType

@onready var interaction = get_node("Interaction")

var tier: int


func _ready():
	interaction.onInteract.connect(interact)
	$"Sprite2D".texture = closedTexture
	if resources.is_empty():
		if type == Enums.chestType.CHEST:
			resources = preload("res://environment/interactions/resources/loot-table-chest-1.tres").resources
		else:
			resources = preload("res://environment/interactions/resources/loot-table-basket-1.tres").resources


func interact(body):
	$"Sprite2D".texture = openedTexture
	if type == Enums.chestType.CHEST:
		global_position -= Vector2(0, 10).rotated(deg_to_rad(get_rotation_degrees()))
	interaction.dropResources(resources, UtilsS.resourceDropSpeed, body)





