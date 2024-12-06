extends Node2D


@export var title: String
@export var availableBlueprints: Array[InventoryResource]
@export var hasAdditionalBlueprints: bool
@export var tier: int
@export var priceModifier: float

@onready var curiosity = get_node("Curiosity")


func _on_curiosity_on_enter():
	var scene = UILoaderS.loadUIScene(preload("res://UI/merchant/merchant-ui.tscn"))
	scene.setup(self)
