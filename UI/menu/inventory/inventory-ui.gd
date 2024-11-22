extends Control


@onready var game = get_tree().get_root().get_node("Game")
@onready var resourcesUI = get_node("HBoxContainer/PanelContainer/ResourcesUI")
@onready var playerStatsUI = get_node("HBoxContainer/PanelContainer2/PlayerStatsUI")


func _ready():
	resourcesUI.updateInventory.connect(updateInventory)
	playerStatsUI.updateInventory.connect(updateInventory)


func updateInventory():
	playerStatsUI.update()
	resourcesUI.updateResourceSlots()
