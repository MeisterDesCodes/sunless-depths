@tool
extends Node2D


@export var texture: Texture2D:
	set(value):
		texture = value
		if $Sprite2D:
			$"Sprite2D".texture = texture
@export var collision: bool = true:
	set(value):
		collision = value
		$"StaticBody2D/CollisionShape2D".disabled = !value
	
