extends Node2D


@export var title: String

@onready var curiosity = get_node("Curiosity")


func _on_curiosity_on_enter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/storage-box/storage-box-ui.tscn"))
	scene.setup(self)

