extends Node2D


@export var title: String
@export var initialDialog: Dialog

@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/dialog/dialog-menu-ui.tscn"))
	scene.setup(self)
