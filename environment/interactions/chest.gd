@tool
extends Node2D


@export var closedTexture: Texture2D:
	set(value):
		closedTexture = value
		$"Sprite2D".texture = closedTexture

@export var openedTexture: Texture2D
@export var resources: Array[DropResource]

@onready var interaction = $"Interaction"


func _ready():
	interaction.onEnter.connect(enter)
	$"Sprite2D".texture = closedTexture


func enter(body):
	$"Sprite2D".texture = openedTexture
	#TODO Fix
	if openedTexture.get_size() > closedTexture.get_size():
		global_position -= Vector2(0, 10).rotated(deg_to_rad(get_rotation_degrees()))
	interaction.dropResources(resources, 100, body)





