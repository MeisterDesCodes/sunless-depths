extends Node


class_name UILoader

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var popupInstance: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/PopupUI")

var fadeTime: float = 0.1
var fadeTimeLoadingScreen: float = 0.5
var currentUIScenes: Array[Control]
var currentLoadingScene: Control
var currentBlockerScene: Control
var currentLabelScene: Control
var currentPopupScene: Control


func loadUIScene(scene: PackedScene):
	playerScene.isInUIScene = true
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeInHeight(sceneInstance, fadeTime)
	currentUIScenes.append(sceneInstance)
	if currentBlockerScene:
		closeUIBlocker(currentBlockerScene)
	loadUIBlocker(preload("res://UI/menu/blocker-ui.tscn"), sceneInstance.z_index - 1)
	return sceneInstance


func loadUIBlocker(scene: PackedScene, index: int):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	sceneInstance.setup(index)
	currentBlockerScene = sceneInstance
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


func loadUIPopup(container, element):
	popupInstance.visible = true
	popupInstance.setup(element)
	
	await get_tree().process_frame
	
	var snapPosition: Vector2
	var offset: float = 10
	var hasXOverflow: bool = false
	
	snapPosition = container.global_position
	snapPosition.x += container.size.x + offset
	
	var endXPosition = container.global_position.x + container.size.x + popupInstance.get_child(0).size.x
	var screenWidth = get_viewport().get_visible_rect().size.x
	if endXPosition > (screenWidth - offset * 2):
		hasXOverflow = true
		snapPosition.x -= (endXPosition - screenWidth + offset * 2)
		
	var test = popupInstance.get_child(0).custom_minimum_size.y
	var endYPosition = container.global_position.y + popupInstance.get_child(0).size.y
	var screenHeight = get_viewport().get_visible_rect().size.y
	if endYPosition > (screenHeight - offset * 2):
		if hasXOverflow:
			snapPosition.y -= (popupInstance.get_child(0).size.y + offset * 2)
		else:
			snapPosition.y -= (endYPosition - screenHeight) + offset * 2
	
	if element is MapPathway:
		snapPosition.x -= container.size.x / 2
	
	popupInstance.global_position = snapPosition
	
	AnimationsS.fadeInHeight(popupInstance, fadeTime)
	currentPopupScene = popupInstance
	return currentPopupScene


func closeUILabel(labelInstance):
	labelInstance.queue_free()
	currentLabelScene = null


func closeLoadingScreen(sceneInstance):
	AnimationsS.fadeOutVisible(sceneInstance, fadeTimeLoadingScreen)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentLoadingScene = null


func closeUIPopup():
	currentPopupScene = null
	AnimationsS.fadeOutHeight(popupInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	if !currentPopupScene:
		popupInstance.visible = false


func closeUIScene(sceneInstance):
	playerScene.atExit = false
	if currentUIScenes.size() == 1:
		playerScene.isInUIScene = false
		closeUIBlocker(currentBlockerScene)
	else:
		currentBlockerScene.z_index = currentUIScenes[currentUIScenes.size() - 2].z_index - 1
	AnimationsS.fadeOutHeight(sceneInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentUIScenes.remove_at(currentUIScenes.find(sceneInstance))


func closeUIBlocker(sceneInstance):
	sceneInstance.queue_free()
	currentBlockerScene = null


func closeAllUIScenes():
	playerScene.isInUIScene = false
	for UIScene in currentUIScenes:
		UIScene.queue_free()
	currentUIScenes.clear()
	if currentBlockerScene:
		closeUIBlocker(currentBlockerScene)
