extends Node


class_name UILoader

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")

var fadeTime: float = 0.1
var fadeTimeLoadingScreen: float = 0.5
var currentUIScenes: Array[Control]
var currentLoadingScene: Control
var currentLabelScene: Control
var currentPopupScene: Control


func loadUIScene(scene: PackedScene):
	playerScene.isInDialog = true
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeInHeight(sceneInstance, fadeTime)
	currentUIScenes.append(sceneInstance)
	return sceneInstance


func loadLoadingScreen(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeInVisible(sceneInstance, fadeTimeLoadingScreen)
	currentLoadingScene = sceneInstance
	return currentLoadingScene


func loadUILabel(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	currentLabelScene = sceneInstance
	return currentLabelScene


func loadUIPopup(container, element, showAdditionalInfo: bool):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var popupInstance = preload("res://UI/shared/popup-ui.tscn").instantiate()
	canvasLayer.add_child(popupInstance)
	popupInstance.setup(element, showAdditionalInfo)
	
	var snapPosition: Vector2
	var offset: float = 10
	
	snapPosition = container.global_position
	snapPosition.x += container.size.x + offset
	
	var endXPosition = container.global_position.x + container.size.x + popupInstance.get_child(0).size.x
	var screenWidth = get_viewport().get_visible_rect().size.x
	if endXPosition > (screenWidth - offset * 2):
		snapPosition.x -= (endXPosition - screenWidth + offset * 2)
		
	var endYPosition = container.global_position.y + popupInstance.get_child(0).size.y
	var screenHeight = get_viewport().get_visible_rect().size.y
	if endYPosition > (screenHeight - offset * 2):
		snapPosition.y -= (popupInstance.get_child(0).size.y + offset * 2)
	
	popupInstance.global_position = snapPosition
	
	AnimationsS.fadeInHeight(popupInstance, fadeTime)
	currentPopupScene = popupInstance
	return currentPopupScene


func closeUILabel(popupInstance):
	popupInstance.queue_free()
	currentLabelScene = null


func closeLoadingScreen(sceneInstance):
	AnimationsS.fadeOutVisible(sceneInstance, fadeTimeLoadingScreen)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentLoadingScene = null


func closeUIPopup(popupInstance):
	AnimationsS.fadeOutHeight(popupInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	popupInstance.queue_free()
	currentPopupScene = null


func closeUIScene(sceneInstance):
	playerScene.isInDialog = false
	AnimationsS.fadeOutHeight(sceneInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentUIScenes.remove_at(currentUIScenes.find(sceneInstance))


func closeAllUIScenes():
	playerScene.isInDialog = false
	for UIScene in currentUIScenes:
		UIScene.queue_free()
	currentUIScenes.clear()
