extends Control


@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var title = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer2/MarginContainer/Label")
@onready var playerResources = get_node("VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/ResourcesUI")
@onready var stationResources = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/MarginContainer/ResourcesUI")


func setup(_craftingStation):
	title.text = _craftingStation.title
	playerResources.updateInventory.connect(updateResources)
	stationResources.updateInventory.connect(updateResources)


func updateResources():
	playerResources.updateResourceSlots()
	stationResources.updateResourceSlots()
