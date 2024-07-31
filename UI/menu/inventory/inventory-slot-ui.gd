extends PanelContainer


signal updateSlot

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var nameLabel: Label = get_node("MarginContainer/HBoxContainer/Name")
@onready var amountLabel: Label = get_node("MarginContainer/HBoxContainer/Amount")
@onready var icon: TextureRect = get_node("MarginContainer/HBoxContainer/PanelContainer/Icon")
@onready var blueprintIcon: PanelContainer = get_node("MarginContainer/HBoxContainer/PanelContainer/BlueprintIcon")
@onready var equipButton: Button = get_node("MarginContainer/EquipButton")
@onready var craftButton: Button = get_node("MarginContainer/CraftButton")
@onready var consumeButton: Button = get_node("MarginContainer/ConsumeButton")
@onready var weaponSlotsContainer: HBoxContainer = get_node("MarginContainer/WeaponSlots")
@onready var ammunitionSlotsConainer: HBoxContainer = get_node("MarginContainer/AmmunitionSlots")

@onready var consumeTexture = preload("res://assets/UI/icons/menu/inventory/Consume.png")

var slot: InventorySlot = null
var popup: Control = null
var loaded: bool = false


func _ready():
	amountLabel.visible = false
	consumeButton.visible = false
	craftButton.visible = false
	equipButton.visible = false
	weaponSlotsContainer.visible = false
	ammunitionSlotsConainer.visible = false
	blueprintIcon.visible = false
	loaded = true


func setup(_slot: InventorySlot):
	if !loaded:
		return
	
	slot = _slot
	match slot.resource.type:
		Enums.resourceType.MATERIAL:
			amountLabel.visible = true
		Enums.resourceType.CONSUMABLE:
			amountLabel.visible = true
			consumeButton.visible = true
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
		
	update(slot)


func update(slot: InventorySlot):
	nameLabel.text = slot.resource.name
	amountLabel.text = str(slot.amount) + "x"
	icon.texture = slot.resource.texture
	
	var themeRegular = preload("res://assets/UI/themes/UI-elements/button-regular.tres")
	var themeSelected = preload("res://assets/UI/themes/UI-elements/button-selected.tres")
	
	if slot.resource in playerScene.equippedGear:
		equipButton.theme = themeSelected
	else:
		equipButton.theme = themeRegular
	
	for i in 3:
		if playerScene.equippedWeapons[i] == slot.resource:
			weaponSlotsContainer.get_child(i).theme = themeSelected
		else:
			weaponSlotsContainer.get_child(i).theme = themeRegular
		weaponSlotsContainer.get_child(i).icon = playerScene.equippedWeapons[i].texture
		
		
		if slot.resource is InventoryAmmunition:
			if playerScene.equippedWeapons[i] is RangedWeapon && playerScene.equippedWeapons[i].ammunition == slot.resource:
				ammunitionSlotsConainer.get_child(i).theme = themeSelected
			else:
				ammunitionSlotsConainer.get_child(i).theme = themeRegular
		ammunitionSlotsConainer.get_child(i).icon = playerScene.equippedWeapons[i].texture


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
	popup.update()


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


func useConsumable():
	disableConsumeButton()
	UtilsS.applyStatusEffects(playerScene, playerScene, slot.resource.statusEffects)
	slot.resource.remainingCooldown = slot.resource.cooldown
	playerScene.inventory.removeResource(slot.resource, 1)


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


func updateConsumeButton():
	if slot.resource.isOnCooldown:
		disableConsumeButton()
	else:
		enableConsumeButton()


func enableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = false
	consumeButton.disabled = false
	slot.resource.remainingCooldown = 0
	consumeButton.icon = consumeTexture
	consumeButton.text = ""


func disableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = true
	consumeButton.disabled = true
	consumeButton.icon = null
	consumeButton.text = str(round(slot.resource.remainingCooldown))














