@tool
extends Node2D


@onready var collisionShape: CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")

@export var texture: Texture2D:
	set(value):
		texture = value
		if $Sprite2D:
			$"Sprite2D".texture = texture


func isMap():
	pass
