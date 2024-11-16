@tool
extends Node2D


@export var texture: Texture2D:
	set(value):
		texture = value
		if $Sprite2D:
			$"Sprite2D".texture = texture


func isMap():
	pass
