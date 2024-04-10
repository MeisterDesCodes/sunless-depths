extends PanelContainer


@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var nameLabel: Label = get_node("NinePatchRect/MarginContainer/HBoxContainer/Name")
@onready var amountLabel: Label = get_node("NinePatchRect/MarginContainer/HBoxContainer/Amount")
@onready var icon: TextureRect = get_node("NinePatchRect/MarginContainer/HBoxContainer/Texture")
@onready var craftContainer: PanelContainer = get_node("NinePatchRect/MarginContainer/Craft")
@onready var weaponSlotsContainer: HBoxContainer = get_node("NinePatchRect/MarginContainer/WeaponSlots")

var slot: InventorySlot = null
var popup: PanelContainer = null


func _ready():
	amountLabel.visible = false
	craftContainer.visible = false
	weaponSlotsContainer.visible = false


func setup(inventorySlot: InventorySlot):
	slot = inventorySlot
	match slot.resource.type:
		Enums.resourceType.MATERIAL:
			amountLabel.visible = true
		Enums.resourceType.USABLE:
			amountLabel.visible = true
		Enums.resourceType.WEAPON:
			weaponSlotsContainer.visible = true
		Enums.resourceType.BLUEPRINT:
			craftContainer.visible = true
			if !playerScene.inventory.hasResources(inventorySlot.resource.inputResources):
				craftContainer.get_children()[1].disabled = true
		
	update(slot)


func update(slot: InventorySlot):
	nameLabel.text = slot.resource.name
	amountLabel.text = str(slot.amount) + "x"
	icon.texture = slot.resource.texture


func _on_craft_button_mouse_entered():
	popup = UILoaderS.loadUIScene(preload("res://UI/inventory/blueprint-popup.tscn"))
	var snapPosition = craftContainer.global_position + Vector2(craftContainer.size.x / 2, 0)
	snapPosition.x -= popup.size.x / 2
	snapPosition.y -= popup.size.y + 20
	popup.setup(slot.resource, snapPosition)
	popup.visible = true


func _on_craft_button_mouse_exited():
	popup.queue_free()


func _on_craft_button_pressed():
	for inputResource in slot.resource.inputResources:
		playerScene.inventory.removeResource(inputResource.resource, inputResource.amount)
	for outputResource in slot.resource.outputResources:
		playerScene.inventory.addResource(outputResource.resource, outputResource.amount)


func equipWeapon(index: int):
	var duplicateWeaponIndex = playerScene.equippedWeapons.find(slot.resource, 0)
	if duplicateWeaponIndex >= 0:
			playerScene.equippedWeapons[duplicateWeaponIndex] = null
	if index != duplicateWeaponIndex:
		playerScene.equippedWeapons[index] = slot.resource
	playerScene.hudUI.setupWeaponTextures()


func _on_assign_slot_1_pressed():
	equipWeapon(0)


func _on_assign_slot_2_pressed():
	equipWeapon(1)


func _on_assign_slot_3_pressed():
	equipWeapon(2)
