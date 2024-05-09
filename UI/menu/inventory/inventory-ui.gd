extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/primary/experience.tres")
@onready var resourceWindow: VBoxContainer = get_node("NinePatchRect2/HBoxContainer/VBoxContainer/ScrollContainer/Resources")

@onready var playerName: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Name")
@onready var background: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Background")
@onready var level: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Level")
@onready var ambition: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Ambition")

@onready var ferocity: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer2/VBoxContainer/Ferocity")
@onready var perseverance: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer2/VBoxContainer2/Perseverance")
@onready var agility: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer2/VBoxContainer3/Agility")
@onready var perception: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer2/VBoxContainer4/Perception")

@onready var currentExperienceLabel: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/HBoxContainer/CurrentExperience")
@onready var experienceCostLabel: Label = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/LevelUp/ExperienceCost")
@onready var levelUpContainer: VBoxContainer = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer3/VBoxContainer/LevelUp")
@onready var levelUpButton: TextureButton = get_node("NinePatchRect2/HBoxContainer/VBoxContainer2/HBoxContainer3/Experience/LevelUpButton")

var currentFilter: Enums.resourceType


func _ready():
	inventory.update.connect(updateAssets)
	updateAssets(Enums.resourceType.RESOURCE)
	updateLabels()
	updateExperience()


func updateLabels():
	playerName.text = playerScene.name
	background.text = ""
	level.text = str(playerScene.level)
	ambition.text = ""
	ferocity.text = str(round(playerScene.entityResource.ferocity))
	perseverance.text = str(round(playerScene.entityResource.perseverance))
	agility.text = str(round(playerScene.entityResource.agility))
	perception.text = str(round(playerScene.entityResource.perception))


func updateExperience():
	var currentExperience: int = playerScene.inventory.getResourceAmount(experience)
	currentExperienceLabel.text = str(currentExperience) + " / " + str(levelUpCost())
	if currentExperience >= levelUpCost():
		levelUpContainer.visible = true
		levelUpButton.visible = true
	else:
		levelUpContainer.visible = false
		levelUpButton.visible = false
	experienceCostLabel.text = "Costs " + str(levelUpCost()) + " Experience"


func levelUpCost():
	return round(pow(5 * (playerScene.level + 1), 1.35))


func levelUp():
	playerScene.inventory.removeResource(experience, levelUpCost())
	playerScene.level += 1
	increaseStats()
	updateExperience()
	updateLabels()


func increaseStats():
	var statIncrease = pow(1.1, playerScene.level)
	playerScene.entityResource.maxHealth += statIncrease * 3
	playerScene.entityResource.ferocity += statIncrease
	playerScene.entityResource.perseverance += statIncrease
	playerScene.entityResource.agility += statIncrease
	playerScene.entityResource.perception += statIncrease


func updateAssets(filter: Enums.resourceType):
	currentFilter = filter
	for resourceSlot in resourceWindow.get_children():
		resourceSlot.queue_free()
	
	var resourceSlots = inventory.resourceSlots if filter == Enums.resourceType.RESOURCE else inventory.resourceSlots.filter(func(slot): return slot.resource.type == filter)
	for resourceSlot in resourceSlots:
		var inventoryResource = preload("res://UI/inventory/inventory-slot-ui.tscn").instantiate()
		resourceWindow.add_child(inventoryResource)
		inventoryResource.setup(resourceSlot)
		inventoryResource.updateInventory.connect(updateAssets.bind(currentFilter))


func _on_all_items_pressed():
	updateAssets(Enums.resourceType.RESOURCE)


func _on_all_materials_pressed():
	updateAssets(Enums.resourceType.MATERIAL)


func _on_all_weapons_pressed():
	updateAssets(Enums.resourceType.WEAPON)


func _on_all_bluprints_pressed():
	updateAssets(Enums.resourceType.BLUEPRINT)


func _on_all_usables_pressed():
	updateAssets(Enums.resourceType.USABLE)


func _on_level_up_button_pressed():
	levelUp()








