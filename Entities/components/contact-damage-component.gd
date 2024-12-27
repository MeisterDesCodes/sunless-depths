extends Node2D


@export var entityScene: CharacterBody2D

@onready var collision: CollisionShape2D = get_node("StaticBody2D/CollisionShape2D")


func _ready():
	await get_tree().process_frame
	
	collision.shape.radius = (entityScene.sprite.texture.get_size().x + \
		entityScene.sprite.texture.get_size().y) / 5 * entityScene.sprite.scale.x
