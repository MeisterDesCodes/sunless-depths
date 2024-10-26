extends Control

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var healthBar: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HealthWindow/VBoxContainer/Health")
@onready var suppliesBar: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer/Supplies")
@onready var oxygenBar: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer/Oxygen")
@onready var staminaBar: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer/Stamina")

@onready var healthLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HealthWindow/VBoxContainer/HealthLabel")
@onready var suppliesLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SuppliesWindow/VBoxContainer/SuppliesLabel")
@onready var oxygenLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/OxygenWindow/VBoxContainer/OxygenLabel")
@onready var staminaLabel: Label = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/StaminaWindow/VBoxContainer/StaminaLabel")


@onready var sprintContainer: PanelContainer = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/MovementIcons/PanelContainer")
@onready var dashContainer: PanelContainer = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/MovementIcons/PanelContainer2")

@onready var allResources = preload("res://inventory-resource/resources/all-resources.tres")

@onready var activeWeapon = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/ActiveWeapon")
@onready var reserveWeapon1 = get_node("MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/ReserveWeapon1")
@onready var reserveWeapon2 = get_node("MarginContainer/HBoxContainer/PanelContainer3/MarginContainer/ReserveWeapon2")

@onready var ammunitionActive = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/PanelContainerAmmunition1/AmmunitionActive")
@onready var ammunitionReserve1 = get_node("MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/PanelContainerAmmunition2/AmmunitionReserve1")
@onready var ammunitionReserve2 = get_node("MarginContainer/HBoxContainer/PanelContainer3/MarginContainer/PanelContainerAmmunition3/AmmunitionReserve2")

@onready var ammunitionActiveLabel = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/PanelContainerAmmunition1/AmmunitionActiveAmount")
@onready var ammunitionReserve1Label = get_node("MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/PanelContainerAmmunition2/AmmunitionReserve1Amount")
@onready var ammunitionReserve2Label = get_node("MarginContainer/HBoxContainer/PanelContainer3/MarginContainer/PanelContainerAmmunition3/AmmunitionReserve2Amount")

@onready var consumableContainer = get_node("MarginContainer/HBoxContainer/PanelContainer4")
@onready var consumableTexture = get_node("MarginContainer/HBoxContainer/PanelContainer4/MarginContainer2/ActiveConsumable")
@onready var consumableAmount = get_node("MarginContainer/HBoxContainer/PanelContainer4/ConsumbleAmount")
@onready var consumableCooldown = get_node("MarginContainer/HBoxContainer/PanelContainer4/ConsumbleCooldown")
@onready var consumeParticles = get_node("ConsumeParticles")
@onready var consumeButton = get_node("MarginContainer/HBoxContainer/PanelContainer4/Button")

@onready var statusEffectsContainer = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/StatusEffects")

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
	sprintContainer.visible = false
	setupWeaponTextures()
	updateConsumable()
	survivalNeedModifier = UtilsS.getScalingValue(playerScene.entityResource.perseverance * 2)
	consumableContainer.pivot_offset = Vector2(consumableContainer.size.x / 2, consumableContainer.size.y / 2)


func updateConsumable():
	consumableTexture.texture = null
	consumableAmount.text = ""
	consumableCooldown.text = ""
	if !playerScene.equippedConsumable:
		consumeButton.disable(UtilsS.colorDisabled)
		return
	
	if !playerScene.equippedConsumable.isOnCooldown:
		if consumeButton.disabled:
			consumeButton.enable()
		consumableTexture.texture = playerScene.equippedConsumable.texture
		consumableAmount.text = str(playerScene.inventory.getResourceAmount(playerScene.equippedConsumable))
	else:
		consumeButton.disable(UtilsS.colorDisabled)
		consumableTexture.texture = null
		consumableAmount.text = ""
		consumableCooldown.text = str(round(playerScene.equippedConsumable.remainingCooldown))


func disableConsumeButton():
	if playerScene.equippedConsumable:
		playerScene.inventory.getResource(playerScene.equippedConsumable).isOnCooldown = true
		updateConsumable()
	
	UtilsS.playUIParticleEffect(consumeParticles, UtilsS.colorPrimary)


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
	
	if playerScene.health < playerScene.maxHealth:
		playerScene.health += playerScene.maxHealth * playerScene.healthRegeneration / 60
		healthModified()
	
	suppliesBar.value -= delta * playerScene.currentSupplyDrain * survivalNeedModifier
	oxygenBar.value -= delta * playerScene.currentOxygenDrain * survivalNeedModifier * 1 / (playerScene.entityResource.oxygenCapacity / 100)
	
	if playerScene.isSprinting:
		staminaBar.value -= delta * (playerScene.sprintingStaminaDrain * playerScene.staminaCostModifier - playerScene.currentStaminaRestore + playerScene.baseStaminaRestore)
	
	if playerScene.isResting:
		staminaBar.value += delta * playerScene.currentStaminaRestore
	
	staminaBar.value += delta * (playerScene.currentStaminaRestore - playerScene.baseStaminaRestore)
	
	if (suppliesBar.value <= 0 && !suppliesIsRestocked):
		restockSupplies()

	if oxygenBar.value <= 0:
		pass
	
	if staminaBar.value <= 0:
		pass


func addStatusEffect(effect: StatusEffect):
	if !getStatusEffectInstance(effect):
		var effectInstance = preload("res://entities/components/status-effect-icon.tscn").instantiate()
		statusEffectsContainer.add_child(effectInstance)
		effectInstance.setup(effect)


func getStatusEffectInstance(_effect: StatusEffect):
	for effectInstance in statusEffectsContainer.get_children():
		if effectInstance.effect.effectType == _effect.effectType:
			return effectInstance
	
	return null


func getMaxDurationEffectInstance(_effect: StatusEffect):
	var maxDurationEffect: StatusEffect = _effect
	for effect in playerScene.statusEffectComponent.statusEffects:
		if effect.effectType == _effect.effectType && effect.remainingDuration / effect.duration \
			> maxDurationEffect.remainingDuration / maxDurationEffect.duration:
			maxDurationEffect = effect
	
	return maxDurationEffect


func getAccumulatedStrength(_effect: StatusEffect):
	var accumulatedStrength: float = 0
	for effect in playerScene.statusEffectComponent.statusEffects:
		if effect.effectType == _effect.effectType:
			accumulatedStrength += effect.strength
	
	return accumulatedStrength


func updateStatusEffects():
	for effectInstance in statusEffectsContainer.get_children():
		effectInstance.effect.maxRemainingDuration = getMaxDurationEffectInstance(effectInstance.effect).remainingDuration
		effectInstance.effect.maxDuration = getMaxDurationEffectInstance(effectInstance.effect).duration
		effectInstance.effect.accumulatedStrength = getAccumulatedStrength(effectInstance.effect)
		effectInstance.update(effectInstance.effect)


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
	sprintContainer.visible = true


func onWalk():
	sprintContainer.visible = false


func onDash():
	dashContainer.visible = false


func onDashCooldown():
	dashContainer.visible = true


func updateHud(suppliesValue, oxygenValue, staminaValue):
	if !suppliesIsRestocked:
		get_tree().create_tween().tween_property(suppliesBar, "value", suppliesBar.value - suppliesValue * survivalNeedModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	if !oxygenIsRestocked:
		get_tree().create_tween().tween_property(oxygenBar, "value", oxygenBar.value - oxygenValue * survivalNeedModifier * 1 / (playerScene.entityResource.oxygenCapacity / 100), 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(staminaBar, "value", staminaBar.value - staminaValue * playerScene.staminaCostModifier, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func healthModified():
	if playerScene:
		get_tree().create_tween().tween_property(healthBar, "value", playerScene.health / playerScene.maxHealth * 100, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		healthLabel.text = str(round(playerScene.health))


func updateLabels():
	suppliesLabel.text = str(playerScene.inventory.getResourceAmount(supplies))
	healthLabel.text = str(round(playerScene.health))


func _on_supplies_timer_timeout():
	suppliesIsRestocked = false


func _on_oxygen_timer_timeout():
	oxygenIsRestocked = false


func _on_panel_container_mouse_entered():
	UILoaderS.loadUIPopup(activeWeapon.get_parent(), playerScene.equippedWeapons[0])


func _on_panel_container_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_2_mouse_entered():
	UILoaderS.loadUIPopup(reserveWeapon1.get_parent(), playerScene.equippedWeapons[1])


func _on_panel_container_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_3_mouse_entered():
	UILoaderS.loadUIPopup(reserveWeapon2.get_parent(), playerScene.equippedWeapons[2])


func _on_panel_container_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_ammunition_1_mouse_entered():
	UILoaderS.loadUIPopup(ammunitionActive.get_parent(), playerScene.equippedWeapons[0].ammunition)


func _on_panel_container_ammunition_1_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_ammunition_2_mouse_entered():
	UILoaderS.loadUIPopup(ammunitionReserve1.get_parent(), playerScene.equippedWeapons[1].ammunition)


func _on_panel_container_ammunition_2_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_panel_container_ammunition_3_mouse_entered():
	UILoaderS.loadUIPopup(ammunitionReserve2.get_parent(), playerScene.equippedWeapons[2].ammunition)


func _on_panel_container_ammunition_3_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_consumable_timer_timeout():
	updateConsumable()


func _on_panel_container_4_mouse_entered():
	if playerScene.equippedConsumable:
		UILoaderS.loadUIPopup(consumableContainer, playerScene.equippedConsumable)


func _on_panel_container_4_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_button_pressed():
	if playerScene.equippedConsumable:
		UtilsS.useConsumable(playerScene, playerScene.equippedConsumable)
		disableConsumeButton()
