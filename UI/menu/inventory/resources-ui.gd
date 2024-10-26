extends Control


signal updateInventory

@export var inventoryType: Enums.inventoryType

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")
@onready var resourceContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/ScrollContainer/Resources")
@onready var filterContainer: HBoxContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2")
@onready var totalWeightContainer: HBoxContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer")
@onready var totalWeightLabel: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/TotalWeight")

var currentFilter: Enums.resourceType


func _ready():
	_on_all_items_pressed()
	updateTotalWeight()
	if inventoryType == Enums.inventoryType.STORAGE_BOX || inventoryType == Enums.inventoryType.CRAFTING_STATION:
		totalWeightContainer.visible = false
	if inventoryType != Enums.inventoryType.STORAGE_BOX:
		playerScene.inventory.createSlot.connect(generateSlot)
	if inventoryType == Enums.inventoryType.STORAGE_BOX:
		playerScene.storage.createSlot.connect(generateSlot)



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
	UtilsS.updateResourceType(resourceSlot.resource)
	var resourceSlotInstance = preload("res://UI/menu/inventory/resource-slot-ui.tscn").instantiate()
	resourceContainer.add_child(resourceSlotInstance)
	resourceSlotInstance.setup(resourceSlot, inventoryType)
	resourceSlotInstance.updateSlot.connect(updateResources)


func updateResources():
	updateInventory.emit()


func updateResourceSlots():
	for slot in resourceContainer.get_children():
		slot.update()
	
	updateTotalWeight()


func updateTotalWeight():
	var totalWeight = playerScene.inventory.getTotalWeight()
	var weightCapacity = playerScene.entityResource.weightCapacity
	totalWeightLabel.text = str(totalWeight) + " / " + str(weightCapacity)
	
	if totalWeight >= weightCapacity:
		totalWeightLabel.self_modulate = UtilsS.colorMissing
	else:
		totalWeightLabel.self_modulate = UtilsS.colorWhite


func getFilteredResources():
	var resourceSlots: Array[InventorySlot]
	match inventoryType:
		Enums.inventoryType.REGULAR:
			resourceSlots = playerScene.inventory.resourceSlots
		Enums.inventoryType.CRAFTING_PLAYER:
			resourceSlots = playerScene.inventory.resourceSlots
		Enums.inventoryType.CRAFTING_STATION:
			var blueprints = LocationLoaderS.currentInteraction.availableBlueprints
			for blueprint in blueprints:
				var newSlot = InventorySlot.new()
				newSlot.resource = blueprint
				newSlot.amount = 1
				resourceSlots.append(newSlot)
		Enums.inventoryType.STORAGE_PLAYER:
			resourceSlots = playerScene.inventory.resourceSlots
		Enums.inventoryType.STORAGE_BOX:
			resourceSlots = playerScene.storage.resourceSlots
	return resourceSlots if currentFilter == Enums.resourceType.RESOURCE \
		else resourceSlots.filter(func(slot): return slot.resource.type == currentFilter)


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

