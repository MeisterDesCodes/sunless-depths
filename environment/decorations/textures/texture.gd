@tool
extends Node2D


@export var texture: Texture:
	set(value):
		texture = value
		$"TextureRect".texture = texture

@export var transparent: bool:
	set(value):
		transparent = value
		if transparent:
			modulate = Color("#FFFFFF", 150)
		else:
			modulate = Color("#FFFFFF")
