extends PanelContainer


signal updateSlot

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var nameLabel: Label = get_node("MarginContainer/HBoxContainer/Name")
@onready var amountLabel: Label = get_node("MarginContainer/HBoxContainer/Amount")
@onready var icon: TextureRect = get_node("MarginContainer/HBoxContainer/PanelContainer/Icon")
@onready var blueprintIcon: PanelContainer = get_node("MarginContainer/HBoxContainer/PanelContainer/BlueprintIcon")
@onready var equipButton: Button = get_node("MarginContainer/EquipButton")
@onready var craftButton: Button = get_node("MarginContainer/CraftButton")
@onready var consumeButton: Button = get_node("MarginContainer/ConsumeSlots/ConsumeButton")
@onready var consumeEquipButton: Button = get_node("MarginContainer/ConsumeSlots/ConsumeEquipButton")
@onready var consumeSlotsContainer: HBoxContainer = get_node("MarginContainer/ConsumeSlots")
@onready var weaponSlotsContainer: HBoxContainer = get_node("MarginContainer/WeaponSlots")
@onready var ammunitionSlotsConainer: HBoxContainer = get_node("MarginContainer/AmmunitionSlots")

@onready var consumeTexture = preload("res://assets/UI/icons/menu/inventory/Consume.png")

var slot: InventorySlot = null
var loaded: bool = false


func _ready():
	amountLabel.visible = false
	consumeSlotsContainer.visible = false
	craftButton.visible = false
	equipButton.visible = false
	weaponSlotsContainer.visible = false
	ammunitionSlotsConainer.visible = false
	blueprintIcon.visible = false
	loaded = true


func setup(_slot: InventorySlot, displayOnly: bool):
	if !loaded:
		return
	
	slot = _slot
	match slot.resource.type:
		Enums.resourceType.MATERIAL:
			amountLabel.visible = true
		Enums.resourceType.CONSUMABLE:
			amountLabel.visible = true
			consumeSlotsContainer.visible = true
			updateConsumeButton()
		Enums.resourceType.WEAPON:
			weaponSlotsContainer.visible = true
		Enums.resourceType.BLUEPRINT:
			blueprintIcon.visible = true
			craftButton.visible = true
			updateCraftButton()
		Enums.resourceType.EQUIPMENT:
			equipButton.visible = true
		Enums.resourceType.AMMUNITION:
			ammunitionSlotsConainer.visible = true
			amountLabel.visible = true
	
	if displayOnly:
		consumeButton.visible = false
		craftButton.visible = false
		equipButton.visible = false
		weaponSlotsContainer.visible = false
		ammunitionSlotsConainer.visible = false
	
	update(slot)


func update(slot: InventorySlot):
	nameLabel.text = slot.resource.name
	amountLabel.text = "x" + str(slot.amount)
	icon.texture = slot.resource.texture
	
	if slot.resource == playerScene.equippedConsumable:
		consumeEquipButton.select()
	else:
		consumeEquipButton.deselect()
	
	if slot.resource in playerScene.equippedGear:
		equipButton.select()
	else:
		equipButton.deselect()
	
	
	for i in 3:
		if playerScene.equippedWeapons[i] == slot.resource:
			weaponSlotsContainer.get_child(i).select()
		else:
			weaponSlotsContainer.get_child(i).deselect()
		#weaponSlotsContainer.get_child(i).get_child(0).texture = playerScene.equippedWeapons[i].texture
		
		if slot.resource is InventoryAmmunition:
			if playerScene.equippedWeapons[i] is RangedWeapon && playerScene.equippedWeapons[i].ammunition == slot.resource:
				ammunitionSlotsConainer.get_child(i).select()
			else:
				ammunitionSlotsConainer.get_child(i).deselect()
			#ammunitionSlotsConainer.get_child(i).get_child(0).texture = playerScene.equippedWeapons[i].texture


func updateCraftButton():
	if !playerScene.inventory.hasResources(slot.resource.inputResources):
		craftButton.disabled = true
	else:
		craftButton.disabled = false


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, slot.resource)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_craft_button_pressed():
	for inputResource in slot.resource.inputResources:
		playerScene.inventory.removeResource(inputResource.resource, inputResource.amount)
	for outputResource in slot.resource.outputResources:
		playerScene.inventory.addResource(outputResource.resource, outputResource.amount)
	updateCraftButton()
	UILoaderS.currentPopupScene.update()


func equipWeapon(index: int):
	if playerScene.equippedWeapons[index] == slot.resource:
		if slot.resource is RangedWeapon:
			playerScene.equippedWeapons[index].ammunition = null
		playerScene.equippedWeapons[index] = playerScene.fistWeapon
	else:
		var duplicateWeaponIndex = playerScene.equippedWeapons.find(slot.resource)
		if duplicateWeaponIndex >= 0:
			playerScene.equippedWeapons[duplicateWeaponIndex] = playerScene.fistWeapon
		if index != duplicateWeaponIndex:
			if playerScene.equippedWeapons[index] is RangedWeapon:
				playerScene.equippedWeapons[index].ammunition = null
			playerScene.equippedWeapons[index] = slot.resource
	
	playerScene.updateWeapons()
	updateSlot.emit()


func equipGear():
	var index = slot.resource.equipmentType
	var currentItem = playerScene.equippedGear[index]
	if currentItem != null:
		UtilsS.unequipItem(playerScene, playerScene.equippedGear[index], index)
	
	if currentItem != slot.resource:
		UtilsS.equipItem(playerScene, slot.resource, index)
		
	updateSlot.emit()


func equipAmmunition(index: int):
	if playerScene.equippedWeapons[index] is RangedWeapon:
		playerScene.equippedWeapons[index].ammunition = slot.resource
		playerScene.updateWeapons()
		updateSlot.emit()


func equipConsumable():
	playerScene.equipConsumable(slot.resource)
	updateSlot.emit()


func useConsumable():
	disableConsumeButton()
	UtilsS.useConsumable(playerScene, slot.resource)


func _on_equip_button_pressed():
	equipGear()


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


func _on_assign_weapon_slot_1_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[0])


func _on_assign_weapon_slot_1_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_weapon_slot_2_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[1])


func _on_assign_weapon_slot_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_weapon_slot_3_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[2])


func _on_assign_weapon_slot_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_ammunition_slot_1_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[0])


func _on_assign_ammunition_slot_1_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_ammunition_slot_2_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[1])


func _on_assign_ammunition_slot_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_ammunition_slot_3_mouse_entered():
	UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[2])


func _on_assign_ammunition_slot_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_consume_button_pressed():
	useConsumable()


func _on_consume_equip_button_pressed():
	equipConsumable()


func updateConsumeButton():
	if slot.resource.isOnCooldown:
		disableConsumeButton()
	else:
		enableConsumeButton()


func enableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = false
	consumeButton.disabled = false
	slot.resource.remainingCooldown = 0
	consumeButton.texture = consumeTexture
	consumeButton.text = ""


func disableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = true
	consumeButton.disabled = true
	consumeButton.texture = null
	consumeButton.text = str(round(slot.resource.remainingCooldown))






