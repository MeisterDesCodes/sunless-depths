extends Node2D


@export var title: String
@export var merchantResources: Array[InventoryResource]
@export var priceModifier: float = 1

@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/merchants/merchant-ui.tscn"))
	scene.setup(self)
