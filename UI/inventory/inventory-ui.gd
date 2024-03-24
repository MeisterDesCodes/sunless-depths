extends Control


@onready var inventory: Inventory = preload("res://UI/inventory/player-inventory.tres")
@onready var resourceWindow: VBoxContainer = get_node("NinePatchRect/ScrollContainer/MarginContainer/Resources")


func _ready():
	inventory.update.connect(updateAssets)
	toggleInventory()
	updateAssets()


func updateAssets():
	for resourceSlot in resourceWindow.get_children():
		resourceSlot.queue_free()
	
	for resourceSlot in inventory.assetSlots:
		var inventoryResource = preload("res://UI/inventory/inventory-slot-ui.tscn").instantiate()
		resourceWindow.add_child(inventoryResource)
		inventoryResource.update(resourceSlot)
		
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		toggleInventory()


func toggleInventory():
	visible = !visible



