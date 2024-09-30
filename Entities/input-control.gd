extends Node2D


@export var playerScene: CharacterBody2D


func _process(delta):
	if playerScene.isInLoadingScreen:
		return
	
	if Input.is_action_just_pressed("exit"):
		if !playerScene.isInUIScene:
			UILoaderS.loadUIScene(preload("res://UI/pause-menu/pause-menu-ui.tscn"))
		else:
			if playerScene.canExitUIScene:
				UILoaderS.closeAllUIScenes()
	
	if playerScene.isInUIScene:
		return
	
	if Input.is_action_just_pressed("inventory"):
		UILoaderS.loadUIScene(preload("res://UI/menu/menu-ui.tscn"))

	if Input.is_action_just_pressed("dash"):
		if (playerScene.canDash && !playerScene.isKnockback && playerScene.hudUI.staminaBar.value > 0):
			playerScene.dash()
	
	if Input.is_action_just_pressed("interact"):
		pass
	
	if Input.is_action_just_pressed("switch-up"):
		playerScene.switchToNextWeapon(-1)
	
	if Input.is_action_just_pressed("switch-down"):
		playerScene.switchToNextWeapon(1)
	
	if Input.is_action_just_pressed("zoom"):
		playerScene.zoom()
	
	if Input.is_action_just_pressed("use-consumable"):
		if playerScene.equippedConsumable && !playerScene.equippedConsumable.isOnCooldown:
			UtilsS.useConsumable(playerScene, playerScene.equippedConsumable)
			playerScene.hudUI.disableConsumeButton()
	
	if Input.get_action_strength("attack"):
		if playerScene.hudUI.staminaBar.value > 0:
			playerScene.attack()
	
	if Input.get_action_strength("save-game"):
		PersistenceS.saveGame()
	
	if Input.get_action_strength("load-game"):
		PersistenceS.loadGame()
	
	if Input.get_action_strength("sprint") && playerScene.hudUI.staminaBar.value > 0:
		playerScene.sprint()
	else:
		playerScene.walk()
