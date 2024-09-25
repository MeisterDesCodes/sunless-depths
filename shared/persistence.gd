extends Node


class_name Persistence

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")


func saveGame():
	var savedData = SavedData.new()
	
	savedData.area = LocationLoaderS.currentLocation
	savedData.position = playerScene.global_position
	savedData.level = playerScene.level
	savedData.health = playerScene.health
	savedData.supplies = playerScene.hudUI.suppliesBar.value
	savedData.oxygen = playerScene.hudUI.oxygenBar.value
	savedData.stamina = playerScene.hudUI.staminaBar.value
	
	savedData.inventory = playerScene.inventory.resourceSlots
	savedData.equippedWeapons = playerScene.equippedWeapons
	savedData.equippedGear = playerScene.equippedGear
	savedData.equippedConsumable = playerScene.equippedConsumable
	savedData.equippedCards = playerScene.equippedCards
	
	ResourceSaver.save(savedData, "res://0-saved-data/saved-game-0.tres")


func loadGame():
	var savedData = load("res://0-saved-data/saved-game-0.tres")
	
	LocationLoaderS.loadArea(savedData.area)
	playerScene.global_position = savedData.position
	
	playerScene.level = savedData.level
	playerScene.health = savedData.health
	playerScene.hudUI.suppliesBar.value = savedData.supplies
	playerScene.hudUI.oxygenBar.value = savedData.oxygen
	playerScene.hudUI.staminaBar.value = savedData.stamina
	
	playerScene.inventory.resourceSlots = savedData.inventory
	playerScene.equippedWeapons = savedData.equippedWeapons
	playerScene.equippedGear = savedData.equippedGear
	playerScene.equippedConsumable = savedData.equippedConsumable
	playerScene.equippedCards = savedData.equippedCards










