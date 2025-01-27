extends Control


@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var playerResources = get_node("VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/ResourcesUI")
@onready var boxResources = get_node("VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/MarginContainer/ResourcesUI")


func setup(_storageBox):
	playerResources.updateInventory.connect(updateResources)
	boxResources.updateInventory.connect(updateResources)


func updateResources():
	playerResources.updateResourceSlots()
	boxResources.updateResourceSlots()


func quickStack(from: Inventory, to: Inventory):
	for i in range(from.resourceSlots.size() - 1, -1, -1):
		var slot = from.resourceSlots[i]
		if to.getResource(slot.resource) && !slot.resource.type == Enums.resourceType.WEAPON \
			&& !slot.resource.type == Enums.resourceType.EQUIPMENT && !slot.resource.type == Enums.resourceType.BLUEPRINT:
			to.addResource(slot.resource, slot.amount)
			from.removeResource(slot.resource, slot.amount)
	
	updateResources()
	playerScene.soundComponent.onEquip()


func _on_stack_all_player_items_pressed():
	quickStack(playerScene.inventory, playerScene.storage)


func _on_stack_all_box_items_pressed():
	quickStack(playerScene.storage, playerScene.inventory)
