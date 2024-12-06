extends Node2D


@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var timer = get_node("Timer")


func clearPath():
	var map = get_tree().get_root().get_node("GameController/Game").get_child(1).get_child(0)
	map.blockage1.queue_free()
	map.blockage2.queue_free()


func respawn():
	game.resetGame()


func suffoctionPowerThrough():
	await UtilsS.createTimer(15)
	UtilsS.applyStatusEffect(playerScene, playerScene, \
		UtilsS.setupEffect(preload("res://entities/resources/status-effects/suffocation.tres"), 25))
	playerScene.wasSuffocating = true
	playerScene.isSuffocating = false


func suffoctionFilter():
	await UtilsS.createTimer(30)
	UtilsS.applyStatusEffect(playerScene, playerScene, \
		UtilsS.setupEffect(preload("res://entities/resources/status-effects/suffocation.tres"), 50))
	playerScene.wasSuffocating = true
	playerScene.isSuffocating = false


func suffoctionFound():
	LocationLoaderS.loadArea(preload("res://UI/menu/map/resources/the-settlement.tres"))
	playerScene.hudUI.updateHud(0, 100, 0)
	playerScene.global_position = Vector2(3150, 500)


func surrender():
	UILoaderS.setupDialog(preload("res://dialogs/resources/player-death/D-initial.tres"), "A Journey's End")


func starvationSuffer():
	UtilsS.applyStatusEffect(playerScene, playerScene, \
		UtilsS.setupEffect(preload("res://entities/resources/status-effects/starvation-1.tres"), 25))
	await UtilsS.createTimer(120)
	playerScene.isStarving = false


func starvationGoMad():
	UtilsS.applyStatusEffect(playerScene, playerScene, \
		UtilsS.setupEffect(preload("res://entities/resources/status-effects/starvation-2.tres"), 50))
	await UtilsS.createTimer(60)
	playerScene.isStarving = false
