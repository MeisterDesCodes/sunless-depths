@tool
extends Node2D


@onready var collisionShape: CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")

@export var texture: Texture2D:
	set(value):
		texture = value
		if $Sprite2D:
			$"Sprite2D".texture = texture
@export var collision: bool = true:
	set(value):
		collision = value
		if collisionShape:
			collisionShape.disabled = !value
@export var collisionRadius: int = 0:
	set(value):
		collisionRadius = value
		if collisionShape:
			var shape = collisionShape.shape.duplicate()
			shape.radius = value
			collisionShape.shape = shape


func _ready():
	if collisionShape && collisionShape.shape is CircleShape2D:
		var shape = collisionShape.shape.duplicate()
		shape.radius = collisionRadius
		collisionShape.shape = shape


func isMap():
	pass
