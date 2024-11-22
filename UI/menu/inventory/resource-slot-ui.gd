extends PanelContainer


signal updateSlot

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var nameLabel: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer3/Name")
@onready var amountContainer: HBoxContainer = get_node("MarginContainer/HBoxContainer/HBoxContainer")
@onready var weightContainer: HBoxContainer = get_node("MarginContainer/HBoxContainer/HBoxContainer2")
@onready var icon: TextureRect = get_node("MarginContainer/HBoxContainer/HBoxContainer3/PanelContainer/Icon")
@onready var blueprintIcon: PanelContainer = get_node("MarginContainer/HBoxContainer/HBoxContainer3/PanelContainer/BlueprintIcon")
@onready var equipButton: Button = get_node("MarginContainer/EquipButton")
@onready var craftButton: Button = get_node("MarginContainer/CraftButton")
@onready var consumeButton: Button = get_node("MarginContainer/ConsumeSlots/ConsumeButton")
@onready var consumeEquipButton: Button = get_node("MarginContainer/ConsumeSlots/ConsumeEquipButton")
@onready var consumeSlotsContainer: HBoxContainer = get_node("MarginContainer/ConsumeSlots")
@onready var weaponSlotsContainer: HBoxContainer = get_node("MarginContainer/WeaponSlots")
@onready var ammunitionSlotsConainer: HBoxContainer = get_node("MarginContainer/AmmunitionSlots")
@onready var playerTransferSlotsConainer: HBoxContainer = get_node("MarginContainer/PlayerTransferSlots")
@onready var boxTransferSlotsConainer: HBoxContainer = get_node("MarginContainer/BoxTransferSlots")
@onready var transferButton: Button = get_node("MarginContainer/TransferButton")
@onready var dropButton: Button = get_node("MarginContainer2/DropButton")

@onready var consumeTexture = preload("res://assets/UI/icons/menu/inventory/Consume.png")

var slot: InventorySlot = null
var loaded: bool = false


func _ready():
	hideAmount()
	consumeSlotsContainer.visible = false
	craftButton.visible = false
	equipButton.visible = false
	weaponSlotsContainer.visible = false
	ammunitionSlotsConainer.visible = false
	blueprintIcon.visible = false
	playerTransferSlotsConainer.visible = false
	boxTransferSlotsConainer.visible = false
	loaded = true


func showAmount():
	amountContainer.get_child(0).texture = preload("res://assets/UI/icons/menu/inventory/Storage.png")
	amountContainer.get_child(1).text = "x" + str(slot.amount)


func hideAmount():
	amountContainer.get_child(0).texture = null
	amountContainer.get_child(1).text = ""


func setup(_slot: InventorySlot, inventoryType: Enums.inventoryType):
	if !loaded:
		return
	
	slot = _slot
	match slot.resource.type:
		Enums.resourceType.MATERIAL:
			showAmount()
		Enums.resourceType.CONSUMABLE:
			showAmount()
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
			showAmount()
	
	if inventoryType != Enums.inventoryType.REGULAR:
		dropButton.visible = false
	
	if inventoryType != Enums.inventoryType.REGULAR && inventoryType != Enums.inventoryType.CRAFTING_STATION:
		consumeButton.visible = false
		consumeEquipButton.visible = false
		craftButton.visible = false
		equipButton.visible = false
		weaponSlotsContainer.visible = false
		ammunitionSlotsConainer.visible = false
	
	if inventoryType == Enums.inventoryType.STORAGE_PLAYER:
		playerTransferSlotsConainer.visible = true
	if inventoryType == Enums.inventoryType.STORAGE_BOX:
		boxTransferSlotsConainer.visible = true
	
	update()


func update():
	if slot.amount == 0:
		UtilsS.unequipResource(playerScene, slot.resource)
		queue_free()
	
	nameLabel.text = slot.resource.name
	if amountContainer.get_child(1).text != "":
		showAmount()
	weightContainer.get_child(1).text = str(slot.resource.weight)
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
		
		weaponSlotsContainer.get_child(i).textureRect.texture = playerScene.equippedWeapons[i].texture
		
		if slot.resource is InventoryAmmunition:
			if playerScene.equippedWeapons[i] is RangedWeapon && playerScene.equippedWeapons[i].ammunition == slot.resource:
				ammunitionSlotsConainer.get_child(i).select()
				ammunitionSlotsConainer.get_child(i).textureRect.texture = playerScene.equippedWeapons[i].ammunition.texture
			else:
				ammunitionSlotsConainer.get_child(i).deselect()


func updateCraftButton():
	if !playerScene.inventory.hasResources(slot.resource.inputResources):
		craftButton.disable()
	else:
		craftButton.enable()


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
	updateSlot.emit()
	UILoaderS.currentPopupScene.update()
	playerScene.soundComponent.onCraft()


func equipWeapon(index: int):
	UtilsS.equipWeapon(playerScene, slot.resource, index)
	updateSlot.emit()
	playerScene.soundComponent.onEquip(slot.resource)


func equipGear():
	var index = slot.resource.equipmentType
	var currentItem = playerScene.equippedGear[index]
	if currentItem != null:
		UtilsS.unequipItem(playerScene, playerScene.equippedGear[index], index)
	
	if currentItem != slot.resource:
		UtilsS.equipItem(playerScene, slot.resource, index)
		
	updateSlot.emit()
	playerScene.soundComponent.onEquip(slot.resource)


func equipAmmunition(index: int):
	if playerScene.equippedWeapons[index] is RangedWeapon:
		playerScene.equippedWeapons[index].ammunition = slot.resource
		playerScene.updateWeapons()
		updateSlot.emit()
		playerScene.soundComponent.onEquip(slot.resource)


func equipConsumable():
	playerScene.equipConsumable(slot.resource)
	updateSlot.emit()
	playerScene.soundComponent.onEquip(slot.resource)


func useConsumable():
	UtilsS.useConsumable(playerScene, slot.resource)
	disableConsumeButton()
	updateSlot.emit()


func transferToBox(amount: int):
	transferResources(playerScene.inventory, playerScene.storage, amount)


func transferToPlayer(amount: int):
	transferResources(playerScene.storage, playerScene.inventory, amount)


func transferResources(from: Inventory, to: Inventory, amount: int):
	if slot.amount < amount:
		amount = slot.amount
	
	from.removeResource(slot.resource, amount)
	to.addResource(slot.resource, amount)
	updateSlot.emit()
	playerScene.soundComponent.onEquip()


func dropResource(amount: int):
	var inventoryAmount: int = playerScene.inventory.getResourceAmount(slot.resource)
	if amount > inventoryAmount:
		amount = inventoryAmount
	
	var dropResource: DropResource = DropResource.new()
	dropResource.resource = slot.resource
	dropResource.amount = amount
	dropResource.dropChance = 1
	playerScene.resourceSpawner.spawnResource(dropResource, Enums.resourceSpawnType.DROP, \
		playerScene.global_position, Vector2.DOWN, UtilsS.resourceDropSpeed * 0.5, true)
	
	playerScene.inventory.removeResource(slot.resource, amount)
	updateSlot.emit()


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
	if playerScene.equippedWeapons[0] is RangedWeapon && playerScene.equippedWeapons[0].ammunition:
		UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[0].ammunition)


func _on_assign_ammunition_slot_1_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_ammunition_slot_2_mouse_entered():
	if playerScene.equippedWeapons[1] is RangedWeapon && playerScene.equippedWeapons[1].ammunition:
		UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[1].ammunition)


func _on_assign_ammunition_slot_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_assign_ammunition_slot_3_mouse_entered():
	if playerScene.equippedWeapons[2] is RangedWeapon && playerScene.equippedWeapons[2].ammunition:
		UILoaderS.loadUIPopup(self, playerScene.equippedWeapons[2].ammunition)


func _on_assign_ammunition_slot_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_consume_button_pressed():
	useConsumable()


func _on_consume_equip_button_pressed():
	equipConsumable()


func updateConsumeButton():
	if !playerScene.inventory.getResource(slot.resource):
		return
	
	if slot.resource.isOnCooldown:
		disableConsumeButton()
	else:
		enableConsumeButton()


func enableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = false
	consumeButton.enable()
	slot.resource.remainingCooldown = 0
	consumeButton.texture = consumeTexture
	consumeButton.text = ""


func disableConsumeButton():
	playerScene.inventory.getResource(slot.resource).isOnCooldown = true
	consumeButton.disable()
	consumeButton.texture = null
	consumeButton.text = str(round(slot.resource.remainingCooldown))


func _on_player_transfer_1_button_pressed():
	transferToBox(1)


func _on_player_transfer_5_button_pressed():
	transferToBox(5)


func _on_player_transfer_all_button_pressed():
	transferToBox(slot.amount)


func _on_box_transfer_1_button_pressed():
	transferToPlayer(1)


func _on_box_transfer_5_button_pressed():
	transferToPlayer(5)


func _on_box_transfer_all_button_pressed():
	transferToPlayer(slot.amount)


func _on_drop_button_pressed():
	if Input.get_action_strength("shift"):
		dropResource(5)
	else:
		dropResource(1)
