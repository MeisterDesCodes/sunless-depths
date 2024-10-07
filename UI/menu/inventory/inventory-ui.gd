extends Control


@onready var resourcesUI = get_node("NinePatchRect2/HBoxContainer/PanelContainer/ResourcesUI")
@onready var playerStatsUI = get_node("NinePatchRect2/HBoxContainer/PanelContainer2/PlayerStatsUI")


func _ready():
	resourcesUI.updateInventory.connect(updateInventory)
	playerStatsUI.updateInventory.connect(updateInventory)


func updateInventory():
	playerStatsUI.updateLabels()
	resourcesUI.updateResourceSlots()
