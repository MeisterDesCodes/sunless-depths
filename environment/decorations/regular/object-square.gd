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
@export var collisionWidth: int = 0:
	set(value):
		collisionWidth = value
		if collisionShape:
			var shape = collisionShape.shape.duplicate()
			shape.size.x = value
			collisionShape.shape = shape
@export var collisionHeight: int = 0:
	set(value):
		collisionHeight = value
		if collisionShape:
			var shape = collisionShape.shape.duplicate()
			shape.size.y = value
			collisionShape.shape = shape


func _ready():
	if collisionShape && collisionShape.shape is RectangleShape2D:
		var shape = collisionShape.shape.duplicate()
		shape.size.x = collisionWidth
		shape.size.y = collisionHeight
		collisionShape.shape = shape


func isMap():
	pass
