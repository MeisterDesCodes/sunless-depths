extends PanelContainer


signal updateSlot

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var nameLabel: Label = get_node("MarginContainer/HBoxContainer/Name")
@onready var amountLabel: Label = get_node("MarginContainer/HBoxContainer/Amount")
@onready var icon: TextureRect = get_node("MarginContainer/HBoxContainer/Texture")
@onready var craftButton: Button = get_node("MarginContainer/CraftButton")
@onready var equipButton: Button = get_node("MarginContainer/EquipButton")
@onready var weaponSlotsContainer: HBoxContainer = get_node("MarginContainer/WeaponSlots")
@onready var ammunitionSlotsConainer: HBoxContainer = get_node("MarginContainer/AmmunitionSlots")

var slot: InventorySlot = null
var popup: Control = null
var loaded: bool = false


func _ready():
	amountLabel.visible = false
	weaponSlotsContainer.visible = false
	craftButton.visible = false
	ammunitionSlotsConainer.visible = false
	equipButton.visible = false
	loaded = true


func setup(_slot: InventorySlot):
	if !loaded:
		return
	
	slot = _slot
	match slot.resource.type:
		Enums.resourceType.MATERIAL:
			amountLabel.visible = true
		Enums.resourceType.USABLE:
			amountLabel.visible = true
		Enums.resourceType.WEAPON:
			weaponSlotsContainer.visible = true
		Enums.resourceType.BLUEPRINT:
			craftButton.visible = true
			updateCraftButton()
		Enums.resourceType.EQUIPMENT:
			equipButton.visible = true
		Enums.resourceType.AMMUNITION:
			ammunitionSlotsConainer.visible = true
			amountLabel.visible = true
		
	update(slot)


func update(slot: InventorySlot):
	nameLabel.text = slot.resource.name
	amountLabel.text = str(slot.amount) + "x"
	icon.texture = slot.resource.texture
	weaponSlotsContainer.get_child(0).icon = playerScene.equippedWeapons[0].texture
	weaponSlotsContainer.get_child(1).icon = playerScene.equippedWeapons[1].texture
	weaponSlotsContainer.get_child(2).icon = playerScene.equippedWeapons[2].texture
	ammunitionSlotsConainer.get_child(0).icon = playerScene.equippedWeapons[0].texture
	ammunitionSlotsConainer.get_child(1).icon = playerScene.equippedWeapons[1].texture
	ammunitionSlotsConainer.get_child(2).icon = playerScene.equippedWeapons[2].texture


func updateCraftButton():
	if !playerScene.inventory.hasResources(slot.resource.inputResources):
		craftButton.disabled = true
	else:
		craftButton.disabled = false


func _on_mouse_entered():
	popup = UILoaderS.loadUIPopup(self, slot.resource, true)


func _on_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_craft_button_pressed():
	for inputResource in slot.resource.inputResources:
		playerScene.inventory.removeResource(inputResource.resource, inputResource.amount)
	for outputResource in slot.resource.outputResources:
		playerScene.inventory.addResource(outputResource.resource, outputResource.amount)
	updateCraftButton()
	popup.update()


func equipWeapon(index: int):
	var duplicateWeaponIndex = playerScene.equippedWeapons.find(slot.resource)
	if duplicateWeaponIndex >= 0:
			playerScene.equippedWeapons[duplicateWeaponIndex] = playerScene.fistWeapon
	if index != duplicateWeaponIndex:
		playerScene.equippedWeapons[index] = slot.resource
	
	playerScene.hudUI.setupWeaponTextures()
	updateSlot.emit()


func equipGear():
	var index = slot.resource.equipmentType
	var currentItem = playerScene.equippedGear[index]
	if currentItem != null:
		unequipItem(playerScene.equippedGear[index], index)
	
	if currentItem != slot.resource:
		equipItem(slot.resource, index)
		
	updateSlot.emit()


func equipAmmunition(index: int):
	if playerScene.equippedWeapons[index] is RangedWeapon:
		playerScene.equippedWeapons[index].ammunition = slot.resource
		playerScene.hudUI.setupWeaponTextures()


func unequipItem(item, index):
	playerScene.entityResource.ferocity -= item.ferocityModifier
	playerScene.entityResource.perseverance -= item.perseveranceModifier
	playerScene.entityResource.agility -= item.agilityModifier
	playerScene.entityResource.perception -= item.perceptionModifier
	playerScene.equippedGear[index] = null


func equipItem(item, index):
	playerScene.entityResource.ferocity += item.ferocityModifier
	playerScene.entityResource.perseverance += item.perseveranceModifier
	playerScene.entityResource.agility += item.agilityModifier
	playerScene.entityResource.perception += item.perceptionModifier
	playerScene.equippedGear[index] = item


func _on_equip_button_pressed():
	equipGear()


func _on_craft_button_mouse_entered():
	popup = UILoaderS.loadUIPopup(self, slot.resource, true)


func _on_craft_button_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_assign_weapon_slot_1_pressed():
	equipWeapon(0)


func _on_assign_weapon_slot_2_pressed():
	equipWeapon(1)


func _on_assign_weapon_slot_3_pressed():
	equipWeapon(2)


func _on_assign_ammunition_slot_1_pressed():
	equipAmmunition(0)


func _on_assign_ammunition_slot_2_pressed():
	equipAmmunition(1)


func _on_assign_ammunition_slot_3_pressed():
	equipAmmunition(2)
