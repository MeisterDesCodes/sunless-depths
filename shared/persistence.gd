extends Node


class_name Persistence

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")


func setup():
	pass


func saveGame():
	UtilsS.removeStatusEffects(playerScene)
	
	var savedData = SavedData.new()
	
	savedData.currentLocation = LocationLoaderS.currentLocation
	savedData.position = playerScene.global_position
	savedData.level = playerScene.level
	savedData.health = playerScene.health
	savedData.supplies = playerScene.hudUI.suppliesBar.value
	savedData.oxygen = playerScene.hudUI.oxygenBar.value
	savedData.stamina = playerScene.hudUI.staminaBar.value
	
	savedData.visitedLocations = LocationLoaderS.visitedLocations
	savedData.exploredLocations = LocationLoaderS.exploredLocations
	savedData.transportableLocations = LocationLoaderS.transportableLocations
	
	savedData.completedDialogChoices = playerScene.completedDialogChoices
	savedData.inventory = playerScene.inventory.resourceSlots
	savedData.storage = playerScene.storage.resourceSlots
	savedData.equippedWeapons = playerScene.equippedWeapons
	for i in playerScene.equippedWeapons.size():
		if playerScene.equippedWeapons[i] is RangedWeapon && playerScene.equippedWeapons[i].ammunition:
			savedData.equippedAmmunitions.append(playerScene.equippedWeapons[i].ammunition)
		else:
			savedData.equippedAmmunitions.append(null)
	
	savedData.equippedGear = playerScene.equippedGear
	savedData.equippedConsumable = playerScene.equippedConsumable
	savedData.equippedCards = playerScene.equippedCards
	
	ResourceSaver.save(savedData, "res://0-saved-data/saved-game-0.tres")


func loadGame():
	UtilsS.removeStatusEffects(playerScene)
	
	var savedData = preload("res://0-saved-data/saved-game-0.tres").duplicate(true)
	var player = preload("res://entities/resources/player/player.tres").duplicate(true)
	
	playerScene.entityResource = player
	
	playerScene.global_position = savedData.position
	
	playerScene.level = savedData.level
	playerScene.health = savedData.health
	playerScene.hudUI.suppliesBar.value = savedData.supplies
	playerScene.hudUI.oxygenBar.value = savedData.oxygen
	playerScene.hudUI.staminaBar.value = savedData.stamina
	
	LocationLoaderS.currentLocation = savedData.currentLocation
	LocationLoaderS.visitedLocations = savedData.visitedLocations
	LocationLoaderS.exploredLocations = savedData.exploredLocations
	LocationLoaderS.transportableLocations = savedData.transportableLocations

	playerScene.completedDialogChoices = savedData.completedDialogChoices
	
	playerScene.inventory.resourceSlots.clear()
	for i in savedData.inventory.size():
		playerScene.inventory.resourceSlots.append( \
			createSlot(savedData.inventory[i].resource, (savedData.inventory[i].amount)))
	
	playerScene.storage.resourceSlots.clear()
	for i in savedData.storage.size():
		playerScene.storage.resourceSlots.append( \
			createSlot(savedData.storage[i].resource, (savedData.storage[i].amount)))

	playerScene.equippedWeapons = savedData.equippedWeapons
	for i in savedData.equippedAmmunitions.size():
		if savedData.equippedAmmunitions[i]:
			playerScene.equippedWeapons[i].ammunition = savedData.equippedAmmunitions[i]
	
	playerScene.equippedGear = savedData.equippedGear
	playerScene.equippedConsumable = playerScene.inventory.getResource(savedData.equippedConsumable)
	playerScene.equippedConsumable.remainingCooldown = 0
	playerScene.equippedConsumable.isOnCooldown = false
	playerScene.equippedCards = savedData.equippedCards


func createSlot(resource: InventoryResource, amount: int):
	var slot: InventorySlot = InventorySlot.new()
	slot.resource = resource
	slot.amount = amount
	return slot




