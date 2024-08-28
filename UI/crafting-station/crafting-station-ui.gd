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
	resourcesUI.displayOnly = true
	resourcesUI.updateAssets(Enums.resourceType.RESOURCE)
	showBlueprints()


func showBlueprints():
	clearResources()
	for blueprint in craftingStation.availableBlueprints:
		var blueprintScene = preload("res://UI/menu/inventory/resource-slot-ui.tscn").instantiate()
		resourcesContainer.add_child(blueprintScene)
		var blueprintSlot = InventorySlot.new()
		blueprintSlot.resource = blueprint
		blueprintSlot.resource.type = Enums.resourceType.BLUEPRINT
		blueprintScene.setup(blueprintSlot, false)


func clearResources():
	for resource in resourcesContainer.get_children():
		resource.get_parent().remove_child(resource)
		resource.queue_free()
