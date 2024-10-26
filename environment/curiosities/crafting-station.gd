extends Node2D


@export var title: String
@export var availableBlueprints: Array[InventoryResource]

@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	LocationLoaderS.currentInteraction = self
	var scene = UILoaderS.loadUIScene(preload("res://UI/crafting-station/crafting-station-ui.tscn"))
	scene.setup(self)
