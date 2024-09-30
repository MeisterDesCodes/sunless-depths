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


func isMap():
	pass
