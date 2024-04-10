extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var supplies = $"NinePatchRect/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer".get_child(0)
@onready var oxygen = $"NinePatchRect/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer".get_child(0)
@onready var stamina = $"NinePatchRect/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer".get_child(0)
@onready var suppliesLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer".get_child(1)
@onready var oxygenLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer".get_child(1)
@onready var staminaLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer".get_child(1)
@onready var health = $"NinePatchRect/HBoxContainer/VBoxContainer2/Health"

@onready var sprintIcon = get_node("NinePatchRect/HBoxContainer/VBoxContainer2/HBoxContainer/RunIcon")
@onready var dashIcon = get_node("NinePatchRect/HBoxContainer/VBoxContainer2/HBoxContainer/DashIcon")

@onready var allResources = preload("res://inventory-resource/resources/all-resources.tres")

@onready var activeWeapon = get_node("Weapons/Panel/ActiveWeapon")
@onready var reserveWeapon1 = get_node("Weapons/Panel3/ReserveWeapon1")
@onready var reserveWeapon2 = get_node("Weapons/Panel2/ReserveWeapon2")

var suppliesBeingRestocked = false
var survivalNeedModifier: float


func _ready():
	playerScene.inventory.update.connect(updateLabels)
	playerScene.updateHud.connect(updateHud)
	playerScene.healthModified.connect(healthModified)
	health.value = 100
	supplies.value = 100
	oxygen.value = 100
	stamina.value = 100
	updateLabels()
	sprintIcon.visible = false
	setupWeaponTextures()
	survivalNeedModifier = UtilsS.getScalingValue(playerScene.entityResource.perseverance * 2)


func setupWeaponTextures():
	activeWeapon.texture = null
	reserveWeapon1.texture = null
	reserveWeapon2.texture = null
	if playerScene.equippedWeapons[0]:
		activeWeapon.texture = playerScene.equippedWeapons[0].texture
	if playerScene.equippedWeapons[1]:
		reserveWeapon1.texture = playerScene.equippedWeapons[1].texture
	if playerScene.equippedWeapons[2]:
		reserveWeapon2.texture = playerScene.equippedWeapons[2].texture
	playerScene.updateActiveWeapon()


func _process(delta):
	if playerScene.isInDialog:
		return
	if playerScene.health < playerScene.entityResource.maxHealth:
		playerScene.health += playerScene.entityResource.maxHealth * playerScene.healthRegeneration / 60
		healthModified()
	
	supplies.value -= delta * playerScene.currentSupplyDrain * survivalNeedModifier
	oxygen.value -= delta * playerScene.currentOxygenDrain * survivalNeedModifier
	stamina.value -= delta * (playerScene.currentStaminaDrain - playerScene.currentStaminaRestore)
	if (supplies.value <= 0 && !suppliesBeingRestocked):
		suppliesBeingRestocked = true
		$"SuppliesTimer".start()
		playerScene.inventory.removeResource(allResources.resources[0], 1)
		updateLabels()
		get_tree().create_tween().tween_property(supplies, "value", 100, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	if (oxygen.value <= 0):
		pass
	if (stamina.value <= 0):
		pass


func onSprint():
	sprintIcon.visible = true


func onWalk():
	sprintIcon.visible = false


func onDash():
	dashIcon.visible = false


func onDashCooldown():
	dashIcon.visible = true


func updateHud(suppliesValue, staminaValue, oxygenValue):
	if !suppliesBeingRestocked:
		get_tree().create_tween().tween_property(supplies, "value", supplies.value - suppliesValue * survivalNeedModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(oxygen, "value", oxygen.value - oxygenValue * survivalNeedModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(stamina, "value", stamina.value - staminaValue, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func healthModified():
	get_tree().create_tween().tween_property(health, "value", playerScene.health / playerScene.entityResource.maxHealth * 100, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func updateLabels():
	suppliesLabel.text = str(playerScene.inventory.getResourceAmount(allResources.resources[0]))
	oxygenLabel.text = str(playerScene.inventory.getResourceAmount(allResources.resources[1]))
	staminaLabel.text = str(playerScene.inventory.getResourceAmount(allResources.resources[2])) 


func _on_supplies_timer_timeout():
	suppliesBeingRestocked = false
