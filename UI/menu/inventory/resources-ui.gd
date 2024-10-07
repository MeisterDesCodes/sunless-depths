extends Control


signal updateInventory

@export var displayOnly: bool

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")
@onready var resourceContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/ScrollContainer/Resources")
@onready var filterContainer: HBoxContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer")

var currentFilter: Enums.resourceType


func _ready():
	_on_all_items_pressed()


func displayResources(filter: Enums.resourceType):
	if !playerScene.isInUIScene:
		return
	
	if filter != Enums.resourceType.NONE:
		currentFilter = filter
	
	for button in filterContainer.get_children():
		button.deselect()
	
	for resourceSlot in resourceContainer.get_children():
		resourceSlot.queue_free()
	
	var resourceSlots = getFilteredResources()
	for resourceSlot in resourceSlots:
		generateSlot(resourceSlot)


func generateSlot(resourceSlot: InventorySlot):
	var resourceSlotInstance = preload("res://UI/menu/inventory/resource-slot-ui.tscn").instantiate()
	resourceContainer.add_child(resourceSlotInstance)
	resourceSlotInstance.setup(resourceSlot, displayOnly)
	resourceSlotInstance.updateSlot.connect(updateResources)


func getFilteredResources():
	return inventory.resourceSlots if currentFilter == Enums.resourceType.RESOURCE \
		else inventory.resourceSlots.filter(func(slot): return slot.resource.type == currentFilter)


func updateResources():
	updateInventory.emit()


func updateResourceSlots():
	var inventorySlots = getFilteredResources()
	var resourceSlots = resourceContainer.get_children()
	for slot in inventorySlots:
		if !resourceSlots.any(func(_slot): return _slot.slot.resource.name == slot.resource.name):
			generateSlot(slot)
	
	for slot in resourceSlots:
		slot.update()



func _on_all_items_pressed():
	displayResources(Enums.resourceType.RESOURCE)
	filterContainer.get_child(0).select()


func _on_all_materials_pressed():
	displayResources(Enums.resourceType.MATERIAL)
	filterContainer.get_child(1).select()


func _on_all_consumables_pressed():
	displayResources(Enums.resourceType.CONSUMABLE)
	filterContainer.get_child(2).select()


func _on_all_blueprints_pressed():
	displayResources(Enums.resourceType.BLUEPRINT)
	filterContainer.get_child(3).select()


func _on_all_weapons_pressed():
	displayResources(Enums.resourceType.WEAPON)
	filterContainer.get_child(4).select()


func _on_all_ammunition_pressed():
	displayResources(Enums.resourceType.AMMUNITION)
	filterContainer.get_child(5).select()


func _on_all_equipment_pressed():
	displayResources(Enums.resourceType.EQUIPMENT)
	filterContainer.get_child(6).select()

