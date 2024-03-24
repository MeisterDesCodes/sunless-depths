extends Node2D


@export var title: String
@export var merchantResources: Array[InventoryResource]
@export var priceModifier: float = 1

@onready var merchantMenuUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/MerchantUI")
@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	merchantMenuUI.setup(self)
