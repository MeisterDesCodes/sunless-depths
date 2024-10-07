extends Control


signal updateInventory

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")

@onready var playerName: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Name")
@onready var background: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Background")
@onready var level: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Level")
@onready var ambition: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Ambition")

@onready var ferocity: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Ferocity")
@onready var perseverance: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/Perseverance")
@onready var agility: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer3/Agility")
@onready var perception: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer4/Perception")

@onready var experienceBar: TextureProgressBar = get_node("MarginContainer/VBoxContainer/HBoxContainer3/Experience")
@onready var currentExperienceLabel: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/CurrentExperience")
@onready var experienceCostLabel: Label = get_node("MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/LevelUp/ExperienceCost")
@onready var levelUpContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/LevelUp")
@onready var levelUpButton: Button = get_node("MarginContainer/VBoxContainer/HBoxContainer3/Experience/LevelUpButton")

var scene


func _ready():
	updateLabels()
	updateExperienceBar()
	experienceBar.pivot_offset = Vector2(experienceBar.size.x / 2, experienceBar.size.y / 2)


func updateLabels():
	playerName.text = playerScene.name
	background.text = ""
	level.text = str(playerScene.level)
	ambition.text = ""
	ferocity.text = str(round(playerScene.entityResource.ferocity))
	perseverance.text = str(round(playerScene.entityResource.perseverance))
	agility.text = str(round(playerScene.entityResource.agility))
	perception.text = str(round(playerScene.entityResource.perception))
	playerScene.updateMaxHealth()


func updateExperienceBar():
	var currentExperience: int = playerScene.inventory.getResourceAmount(experience)
	experienceBar.value = currentExperience / levelUpCost() * 100
	currentExperienceLabel.text = str(currentExperience) + " / " + str(levelUpCost())
	if currentExperience >= levelUpCost():
		levelUpContainer.visible = true
		levelUpButton.visible = true
	else:
		levelUpContainer.visible = false
		levelUpButton.visible = false
	experienceCostLabel.text = "Costs " + str(levelUpCost()) + " Experience"


func levelUpCost():
	return round((8 + 12 * playerScene.level) * pow(1.125, playerScene.level))


func levelUp():
	playerScene.inventory.removeResource(experience, levelUpCost())
	playerScene.level += 1
	updateExperienceBar()
	scene = UILoaderS.loadUIScene(preload("res://UI/menu/inventory/level-up-cards/level-up-ui.tscn"))
	scene.cardSelected.connect(updateStats)
	playerScene.canExitUIScene = false


func updateStats():
	updateInventory.emit()


func _on_level_up_button_pressed():
	levelUp()


func _on_level_up_button_mouse_entered():
	if levelUpButton.disabled:
		return
	
	AnimationsS.changeColor(experienceBar, UtilsS.colorPrimaryBright, 0.15)
	AnimationsS.setSize(experienceBar, 1.025, 0.15)


func _on_level_up_button_mouse_exited():
	if levelUpButton.disabled:
		return
	
	AnimationsS.changeColor(experienceBar, UtilsS.colorWhite, 0.15)
	AnimationsS.setSize(experienceBar, 1, 0.15)
