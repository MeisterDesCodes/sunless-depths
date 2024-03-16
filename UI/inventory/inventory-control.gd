extends Control


@onready var inventory: Inventory = preload("res://UI/inventory/player-inventory.tres")
@onready var assetSlots: Array = $"NinePatchRect/ScrollContainer/MarginContainer/GridContainer".get_children()

var isOpen: bool = true


func _ready():
	inventory.update.connect(updateAssets)
	toggleInventory()
	updateAssets()
	
	
func updateAssets():
	for i in range(min(inventory.assetSlots.size(), assetSlots.size())):
		assetSlots[i].update(inventory.assetSlots[i])
		
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		toggleInventory()
	
	
func toggleInventory():
	isOpen = !isOpen
	visible = !visible



