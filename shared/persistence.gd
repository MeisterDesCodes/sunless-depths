extends Node


class_name Persistence

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")


func saveGame():
	for i in range(playerScene.statusEffectComponent.statusEffects.size() - 1, -1, -1):
		playerScene.statusEffectComponent.statusEffects[i].onExpire(playerScene)
	
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
	var savedData = load("res://0-saved-data/saved-game-0.tres")
	
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
	playerScene.inventory.resourceSlots = savedData.inventory
	playerScene.storage.resourceSlots = savedData.storage
	playerScene.equippedWeapons = savedData.equippedWeapons
	for i in savedData.equippedAmmunitions.size():
		if savedData.equippedAmmunitions[i]:
			playerScene.equippedWeapons[i].ammunition = savedData.equippedAmmunitions[i]
	
	playerScene.equippedGear = savedData.equippedGear
	playerScene.equippedConsumable = savedData.equippedConsumable
	playerScene.equippedCards = savedData.equippedCards
	
	return savedData









