extends Control


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
	playerScene.updateMaxHealth()


func updateExperience():
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
	updateExperience()
	updateLabels()
	scene = UILoaderS.loadUIScene(preload("res://UI/menu/inventory/level-up/level-up-ui.tscn"))
	scene.cardSelected.connect(updateLabels)


func _on_level_up_button_pressed():
	levelUp()
