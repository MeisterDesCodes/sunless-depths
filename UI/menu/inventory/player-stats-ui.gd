extends Control


signal updateInventory

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var inventory: Inventory = preload("res://inventory-resource/resources/player/player-inventory.tres")
@onready var experience: InventoryResource = preload("res://inventory-resource/resources/material/primary/experience.tres")

@onready var ferocity: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer/HBoxContainer/Ferocity")
@onready var perseverance: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer2/HBoxContainer/Perseverance")
@onready var agility: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/Agility")
@onready var perception: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer4/HBoxContainer/Perception")

@onready var ferocityBar: TextureProgressBar = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer/HBoxContainer/TextureProgressBar")
@onready var perseveranceBar: TextureProgressBar = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer2/HBoxContainer/TextureProgressBar")
@onready var agilityBar: TextureProgressBar = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer3/HBoxContainer/TextureProgressBar")
@onready var perceptionBar: TextureProgressBar = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer2/VBoxContainer4/HBoxContainer/TextureProgressBar")

@onready var levelLabel: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer3/VBoxContainer/Level")
@onready var experienceBar: TextureProgressBar = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Experience")
@onready var experienceLabel: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer3/VBoxContainer/HBoxContainer/ExperienceLabel")
@onready var levelUpLabel: Label = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer3/VBoxContainer/Label")
@onready var levelUpButton: Button = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Experience/LevelUpButton")

@onready var weaponsContainer: HBoxContainer = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer3/WeaponContainer")
@onready var equipmentContainer: HBoxContainer = get_node("MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer4/EquipmentContainer")

var scene


func _ready():
	experienceBar.pivot_offset = Vector2(experienceBar.size.x / 2, experienceBar.size.y / 2)
	update()


func update():
	updateLabels()
	updateBars()
	updateExperienceBar()
	updateEquipment()


func updateLabels():
	levelLabel.text = "Level " + str(playerScene.level)
	ferocity.text = str(round(playerScene.entityResource.ferocity))
	perseverance.text = str(round(playerScene.entityResource.perseverance))
	agility.text = str(round(playerScene.entityResource.agility))
	perception.text = str(round(playerScene.entityResource.perception))
	playerScene.updateMaxHealth()


func updateBars():
	var modifier: float = 2
	ferocityBar.value = playerScene.entityResource.ferocity * modifier
	perseveranceBar.value = playerScene.entityResource.perseverance * modifier
	agilityBar.value = playerScene.entityResource.agility * modifier
	perceptionBar.value = playerScene.entityResource.perception * modifier


func updateExperienceBar():
	var currentExperience: int = playerScene.inventory.getResourceAmount(experience)
	experienceBar.value = currentExperience / levelUpCost() * 100
	experienceLabel.text = str(currentExperience) + " / " + str(levelUpCost())
	if currentExperience >= levelUpCost():
		levelUpLabel.visible = true
		levelUpButton.enable()
	else:
		levelUpLabel.visible = false
		levelUpButton.disable(UtilsS.colorDisabled)


func updateEquipment():
	var i: int = 0
	for weapon in weaponsContainer.get_children():
		weapon.get_child(0).texture = playerScene.equippedWeapons[i].texture
		i += 1
		
	i = 0
	for equipment in equipmentContainer.get_children():
		if playerScene.equippedGear[i]:
			equipment.get_child(0).texture = playerScene.equippedGear[i].texture
		else:
			equipment.get_child(0).texture = null
		i += 1


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


func _on_panel_container_mouse_entered():
	UILoaderS.loadUIPopup(weaponsContainer.get_child(0), playerScene.equippedWeapons[0])


func _on_panel_container_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_2_mouse_entered():
	UILoaderS.loadUIPopup(weaponsContainer.get_child(1), playerScene.equippedWeapons[1])


func _on_panel_container_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_3_mouse_entered():
	UILoaderS.loadUIPopup(weaponsContainer.get_child(2), playerScene.equippedWeapons[2])


func _on_panel_container_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_4_mouse_entered():
	if playerScene.equippedGear[0]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(0), playerScene.equippedGear[0])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(0), "Unused slot")


func _on_panel_container_4_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_5_mouse_entered():
	if playerScene.equippedGear[1]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(1), playerScene.equippedGear[1])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(1), "Unused slot")


func _on_panel_container_5_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_6_mouse_entered():
	if playerScene.equippedGear[2]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(2), playerScene.equippedGear[2])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(2), "Unused slot")


func _on_panel_container_6_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_7_mouse_entered():
	if playerScene.equippedGear[3]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(3), playerScene.equippedGear[3])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(3), "Unused slot")


func _on_panel_container_7_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_8_mouse_entered():
	if playerScene.equippedGear[4]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(4), playerScene.equippedGear[4])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(4), "Unused slot")


func _on_panel_container_8_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_9_mouse_entered():
	if playerScene.equippedGear[5]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(5), playerScene.equippedGear[5])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(5), "Unused slot")


func _on_panel_container_9_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_10_mouse_entered():
	if playerScene.equippedGear[6]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(6), playerScene.equippedGear[6])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(6), "Unused slot")


func _on_panel_container_10_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()


func _on_panel_container_11_mouse_entered():
	if playerScene.equippedGear[7]:
		UILoaderS.loadUIPopup(equipmentContainer.get_child(7), playerScene.equippedGear[7])
	else:
		UILoaderS.loadUITooltip(equipmentContainer.get_child(7), "Unused slot")


func _on_panel_container_11_mouse_exited():
	UILoaderS.closeUIPopup()
	UILoaderS.closeUITooltip()
