extends Node2D


@export var title: String
@export var availableBlueprints: Array[InventoryResource]
@export var priceModifier: float

@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/merchant/merchant-ui.tscn"))
	scene.setup(self)
