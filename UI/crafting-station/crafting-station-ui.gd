extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")
@onready var title = get_node("VBoxContainer/HBoxContainer/PanelContainer2/MarginContainer/LocationContainer/PanelContainer/Title")

@onready var resourcesContainer = get_node("VBoxContainer/HBoxContainer/PanelContainer2/MarginContainer/LocationContainer/ScrollContainer/Resources")
@onready var resourcesUI = get_node("VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ResourcesUI")

var craftingStation = null


func setup(_craftingStation):
	craftingStation = _craftingStation
	title.text = craftingStation.title
	displayBlueprints()


func displayBlueprints():
	for blueprint in craftingStation.availableBlueprints:
		var blueprintScene = preload("res://UI/menu/inventory/resource-slot-ui.tscn").instantiate()
		resourcesContainer.add_child(blueprintScene)
		var blueprintSlot = InventorySlot.new()
		blueprintSlot.resource = blueprint
		blueprintSlot.amount = 1
		blueprintSlot.resource.type = Enums.resourceType.BLUEPRINT
		blueprintScene.setup(blueprintSlot, false)
		blueprintScene.updateSlot.connect(updateResourceSlots)


func updateResourceSlots():
	resourcesUI.updateResourceSlots()
