extends Control


signal updateResources

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")
@onready var resourceContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/ScrollContainer/Resources")

var currentFilter: Enums.resourceType


func _ready():
	inventory.updateInventory.connect(updateAssets)
	updateAssets(Enums.resourceType.RESOURCE)


func updateAssets(filter: Enums.resourceType):
	if !playerScene.isInDialog:
		return
	
	if filter != Enums.resourceType.NONE:
		currentFilter = filter
	
	for resourceSlot in resourceContainer.get_children():
		resourceSlot.queue_free()
	
	var resourceSlots = inventory.resourceSlots if currentFilter == Enums.resourceType.RESOURCE else inventory.resourceSlots.filter(func(slot): return slot.resource.type == currentFilter)
	for resourceSlot in resourceSlots:
		var inventoryResource = preload("res://UI/menu/inventory/inventory-slot-ui.tscn").instantiate()
		resourceContainer.add_child(inventoryResource)
		inventoryResource.setup(resourceSlot)
		inventoryResource.updateSlot.connect(update)


func update():
	updateResources.emit()


func _on_all_items_pressed():
	updateAssets(Enums.resourceType.RESOURCE)


func _on_all_materials_pressed():
	updateAssets(Enums.resourceType.MATERIAL)


func _on_all_usables_pressed():
	updateAssets(Enums.resourceType.USABLE)


func _on_all_bluprints_pressed():
	updateAssets(Enums.resourceType.BLUEPRINT)


func _on_all_weapons_pressed():
	updateAssets(Enums.resourceType.WEAPON)


func _on_all_ammunition_pressed():
	updateAssets(Enums.resourceType.AMMUNITION)


func _on_all_equipment_pressed():
	updateAssets(Enums.resourceType.EQUIPMENT)
