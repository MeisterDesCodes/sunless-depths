extends Control


signal updateResources

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")
@onready var resourceContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/ScrollContainer/Resources")
@onready var filterContainer: HBoxContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer")

var displayOnly: bool = false
var currentFilter: Enums.resourceType


func _ready():
	inventory.updateInventory.connect(updateAssets)
	_on_all_items_pressed()


func updateAssets(filter: Enums.resourceType):
	if !playerScene.isInUIScene:
		return
	
	if filter != Enums.resourceType.NONE:
		currentFilter = filter
	
	for button in filterContainer.get_children():
		button.deselect()
	
	for resourceSlot in resourceContainer.get_children():
		resourceSlot.queue_free()
	
	var resourceSlots = inventory.resourceSlots if currentFilter == Enums.resourceType.RESOURCE else inventory.resourceSlots.filter(func(slot): return slot.resource.type == currentFilter)
	for resourceSlot in resourceSlots:
		var resourceSlotInstance = preload("res://UI/menu/inventory/resource-slot-ui.tscn").instantiate()
		resourceContainer.add_child(resourceSlotInstance)
		resourceSlotInstance.setup(resourceSlot, displayOnly)
		resourceSlotInstance.updateSlot.connect(update)


func update():
	updateResources.emit()


func _on_all_items_pressed():
	updateAssets(Enums.resourceType.RESOURCE)
	filterContainer.get_child(0).select()


func _on_all_materials_pressed():
	updateAssets(Enums.resourceType.MATERIAL)
	filterContainer.get_child(1).select()


func _on_all_consumables_pressed():
	updateAssets(Enums.resourceType.CONSUMABLE)
	filterContainer.get_child(2).select()


func _on_all_blueprints_pressed():
	updateAssets(Enums.resourceType.BLUEPRINT)
	filterContainer.get_child(3).select()


func _on_all_weapons_pressed():
	updateAssets(Enums.resourceType.WEAPON)
	filterContainer.get_child(4).select()


func _on_all_ammunition_pressed():
	updateAssets(Enums.resourceType.AMMUNITION)
	filterContainer.get_child(5).select()


func _on_all_equipment_pressed():
	updateAssets(Enums.resourceType.EQUIPMENT)
	filterContainer.get_child(6).select()

