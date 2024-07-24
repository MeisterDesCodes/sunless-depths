extends Node2D


@export var playerScene: CharacterBody2D


func _process(delta):
	if !playerScene.canAct():
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
	
	if Input.get_action_strength("attack"):
		if playerScene.hudUI.staminaBar.value > 0:
			playerScene.attack()
	
	if Input.get_action_strength("sprint") && playerScene.hudUI.staminaBar.value > 0:
		playerScene.sprint()
	else:
		playerScene.walk()
