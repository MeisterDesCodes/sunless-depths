extends Control


@onready var textureRect: TextureRect = get_node("TextureRect")


func setup(texture: Texture):
	textureRect.texture = texture
