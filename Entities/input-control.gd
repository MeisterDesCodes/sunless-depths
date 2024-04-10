extends Node2D


@export var playerScene: CharacterBody2D


func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		var scene = preload("res://UI/inventory/inventory-ui.tscn")
		if !UILoaderS.isSceneOpen(scene):
			UILoaderS.loadUIScene(scene)
		else:
			UILoaderS.closeUIScene(scene)
			playerScene.isInDialog = false
	
	if playerScene.isInDialog:
		return
	
	if Input.is_action_just_pressed("dash"):
		if (playerScene.canDash && !playerScene.isKnockback && playerScene.hudUI.stamina.value > playerScene.dashStaminaCost):
			playerScene.canDash = false
			playerScene.isDashing = true
			playerScene.hudUI.onDash()
			playerScene.updateHud.emit(1, playerScene.dashStaminaCost, 2)
			var dash_vector = global_position.direction_to(get_global_mouse_position()) * 400
			playerScene.velocity = lerp(playerScene.velocity, dash_vector, 0.5)
			$"../DashTimer".start()
			await get_tree().create_timer(0.3).timeout
			playerScene.isDashing = false
	
	if Input.is_action_just_pressed("interact"):
		pass
	
	if Input.is_action_just_pressed("switch-up"):
		playerScene.switchToNextWeapon(-1)
	
	if Input.is_action_just_pressed("switch-down"):
		playerScene.switchToNextWeapon(1)
	
	if Input.get_action_strength("attack"):
		if playerScene.hudUI.stamina.value >= playerScene.weaponInstance.weapon.staminaCost:
			playerScene.attack()
	
	if Input.get_action_strength("sprint") && playerScene.hudUI.stamina.value > 0:
		playerScene.isSprinting = true
		playerScene.hudUI.onSprint()
		playerScene.currentSupplyDrain = playerScene.entityResource.supplyDrain + 1.25
		playerScene.currentOxygenDrain = playerScene.entityResource.supplyDrain + 0.75
		playerScene.currentStaminaDrain = 10
		playerScene.currentStaminaRestore = 0
		$"../StaminaRestore".start()
	else:
		playerScene.isSprinting = false
		playerScene.hudUI.onWalk()
		playerScene.currentSupplyDrain = playerScene.entityResource.supplyDrain
		playerScene.currentOxygenDrain = playerScene.entityResource.oxygenDrain
		playerScene.currentStaminaDrain = playerScene.entityResource.staminaDrain