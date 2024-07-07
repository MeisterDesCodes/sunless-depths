extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var healthBar: TextureProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Health")
@onready var suppliesBar: TextureProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer/Supplies")
@onready var oxygenBar: TextureProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer/Oxygen")
@onready var staminaBar: TextureProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer/Stamina")

@onready var suppliesLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer/SuppliesLabel")
@onready var oxygenLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer/OxygenLabel")
@onready var staminaLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer/StaminaLabel")


@onready var sprintIcon: PanelContainer = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer")
@onready var dashIcon: PanelContainer = get_node("MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer2")

@onready var allResources = preload("res://inventory-resource/resources/all-resources.tres")

@onready var activeWeapon = get_node("MarginContainer/HBoxContainer/PanelContainer/ActiveWeapon")
@onready var reserveWeapon1 = get_node("MarginContainer/HBoxContainer/PanelContainer2/ReserveWeapon1")
@onready var reserveWeapon2 = get_node("MarginContainer/HBoxContainer/PanelContainer3/ReserveWeapon2")

@onready var ammunitionActive = get_node("MarginContainer/HBoxContainer/PanelContainer/PanelContainerAmmunition1/AmmunitionActive")
@onready var ammunitionReserve1 = get_node("MarginContainer/HBoxContainer/PanelContainer2/PanelContainerAmmunition2/AmmunitionReserve1")
@onready var ammunitionReserve2 = get_node("MarginContainer/HBoxContainer/PanelContainer3/PanelContainerAmmunition3/AmmunitionReserve2")

@onready var ammunitionActiveLabel = get_node("MarginContainer/HBoxContainer/PanelContainer/PanelContainerAmmunition1/AmmunitionActiveAmount")
@onready var ammunitionReserve1Label = get_node("MarginContainer/HBoxContainer/PanelContainer2/PanelContainerAmmunition2/AmmunitionReserve1Amount")
@onready var ammunitionReserve2Label = get_node("MarginContainer/HBoxContainer/PanelContainer3/PanelContainerAmmunition3/AmmunitionReserve2Amount")

@onready var weaponSlots: Array = [activeWeapon, reserveWeapon1, reserveWeapon2]
@onready var ammunitionSlots: Array = [ammunitionActive, ammunitionReserve1, ammunitionReserve2]
@onready var weaponSlotLabels: Array = [ammunitionActiveLabel, ammunitionReserve1Label, ammunitionReserve2Label]

var supplies = preload("res://inventory-resource/resources/material/primary/supplies.tres")
var oxygen = preload("res://inventory-resource/resources/material/primary/oxygen.tres")
var stamina = preload("res://inventory-resource/resources/material/primary/stamina.tres")

var popup: Control = null
var suppliesIsRestocked = false
var oxygenIsRestocked = false
var survivalNeedModifier: float


func _ready():
	playerScene.inventory.updateInventory.connect(updateLabels)
	playerScene.updateHud.connect(updateHud)
	playerScene.healthModified.connect(healthModified)
	healthBar.value = 100
	suppliesBar.value = 100
	oxygenBar.value = 100
	staminaBar.value = 100
	updateLabels()
	sprintIcon.visible = false
	setupWeaponTextures()
	survivalNeedModifier = UtilsS.getScalingValue(playerScene.entityResource.perseverance * 2)


func setupWeaponTexture(index: int):
	weaponSlots[index].texture = playerScene.fistWeapon.texture
	ammunitionSlots[index].get_parent().visible = false
	
	var weapon = playerScene.equippedWeapons[index]
	weaponSlots[index].texture = weapon.texture
	if weapon is RangedWeapon && weapon.ammunition:
		ammunitionSlots[index].get_parent().visible = true
		ammunitionSlots[index].texture = weapon.ammunition.texture
		weaponSlotLabels[index].text = str(playerScene.inventory.getResourceAmount(weapon.ammunition))


func setupWeaponTextures():
	for i in 3:
		setupWeaponTexture(i)
	
	playerScene.updateActiveWeapon()


func _process(delta):
	if !playerScene.canAct():
		return
	
	if playerScene.health < playerScene.entityResource.maxHealth:
		playerScene.health += playerScene.entityResource.maxHealth * playerScene.healthRegeneration / 60
		healthModified()
	
	suppliesBar.value -= delta * playerScene.currentSupplyDrain * survivalNeedModifier
	oxygenBar.value -= delta * playerScene.currentOxygenDrain * survivalNeedModifier
	staminaBar.value -= delta * (playerScene.currentStaminaDrain - playerScene.currentStaminaRestore)
	if (suppliesBar.value <= 0 && !suppliesIsRestocked):
		restockSupplies()

	if oxygenBar.value <= 0:
		pass
	
	if staminaBar.value <= 0:
		pass


func restockSupplies():
	suppliesIsRestocked = true
	$"SuppliesTimer".start()
	playerScene.inventory.removeResource(supplies, 1)
	updateLabels()
	get_tree().create_tween().tween_property(suppliesBar, "value", 100, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func restockOxygen():
	oxygenIsRestocked = true
	$"OxygenTimer".start()
	get_tree().create_tween().tween_property(oxygenBar, "value", 100, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func onSprint():
	sprintIcon.visible = true


func onWalk():
	sprintIcon.visible = false


func onDash():
	dashIcon.visible = false


func onDashCooldown():
	dashIcon.visible = true


func updateHud(suppliesValue, oxygenValue, staminaValue):
	if !suppliesIsRestocked:
		get_tree().create_tween().tween_property(suppliesBar, "value", suppliesBar.value - suppliesValue * survivalNeedModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	if !oxygenIsRestocked:
		get_tree().create_tween().tween_property(oxygenBar, "value", oxygenBar.value - oxygenValue * survivalNeedModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(staminaBar, "value", staminaBar.value - staminaValue, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func healthModified():
	get_tree().create_tween().tween_property(healthBar, "value", playerScene.health / playerScene.entityResource.maxHealth * 100, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func updateLabels():
	suppliesLabel.text = str(playerScene.inventory.getResourceAmount(supplies))


func _on_supplies_timer_timeout():
	suppliesIsRestocked = false


func _on_oxygen_timer_timeout():
	oxygenIsRestocked = false


func _on_panel_container_mouse_entered():
	popup = UILoaderS.loadUIPopup(activeWeapon.get_parent(), playerScene.equippedWeapons[0], true)


func _on_panel_container_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_panel_container_2_mouse_entered():
	popup = UILoaderS.loadUIPopup(reserveWeapon1.get_parent(), playerScene.equippedWeapons[1], true)


func _on_panel_container_2_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_panel_container_3_mouse_entered():
	popup = UILoaderS.loadUIPopup(reserveWeapon2.get_parent(), playerScene.equippedWeapons[2], true)


func _on_panel_container_3_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_panel_container_ammunition_1_mouse_entered():
	popup = UILoaderS.loadUIPopup(ammunitionActive.get_parent(), playerScene.equippedWeapons[0].ammunition, true)


func _on_panel_container_ammunition_1_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_panel_container_ammunition_2_mouse_entered():
	popup = UILoaderS.loadUIPopup(ammunitionReserve1.get_parent(), playerScene.equippedWeapons[1].ammunition, true)


func _on_panel_container_ammunition_2_mouse_exited():
	UILoaderS.closeUIPopup(popup)


func _on_panel_container_ammunition_3_mouse_entered():
	popup = UILoaderS.loadUIPopup(ammunitionReserve2.get_parent(), playerScene.equippedWeapons[2].ammunition, true)


func _on_panel_container_ammunition_3_mouse_exited():
	UILoaderS.closeUIPopup(popup)
