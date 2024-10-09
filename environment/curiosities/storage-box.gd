extends Node2D


@export var title: String

@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/storage-box/storage-box-ui.tscn"))
	scene.setup(self)
