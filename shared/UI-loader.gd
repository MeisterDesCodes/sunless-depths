extends Node


class_name UILoader

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var popupInstance: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/PopupMenuUI")
@onready var tooltipInstance: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/TooltipUI")

var fadeTime: float = 0.1
var fadeTimeOverlay: float = 0.2
var fadeTimeLoadingScreen: float = 0.5
var currentUIScenes: Array[Control]
var currentLoadingScene: Control
var currentBlockerScene: Control
var currentLabelScene: Control
var currentOverlayScene: Control
var currentPopupScene: Control
var currentTooltipScene: Control


func loadUIScene(scene: PackedScene):
	playerScene.isInUIScene = true
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeHeight(sceneInstance, 1, fadeTime)
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


func loadUILoadingScreen(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeVisible(sceneInstance, 1, fadeTimeLoadingScreen)
	currentLoadingScene = sceneInstance
	return currentLoadingScene


func loadUIOverlay(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeWidth(sceneInstance.get_child(0), 1, fadeTimeOverlay)
	currentOverlayScene = sceneInstance
	return currentOverlayScene


func loadUIPopup(container, element):
	popupInstance.visible = true
	popupInstance.setup(element)
	
	await get_tree().process_frame
	
	var snapPosition = getInstancePosition(container, popupInstance)
	if element is MapPathway:
		snapPosition.x -= container.size.x / 2
	popupInstance.global_position = snapPosition
	
	AnimationsS.fadeHeight(popupInstance, 1, fadeTime)
	currentPopupScene = popupInstance
	return currentPopupScene


func loadUITooltip(container, text: String):
	tooltipInstance.visible = true
	tooltipInstance.setup(text)
	
	await get_tree().process_frame
	
	tooltipInstance.global_position = getInstancePosition(container, tooltipInstance)
	
	AnimationsS.fadeHeight(tooltipInstance, 1, fadeTime)
	currentTooltipScene = tooltipInstance
	return currentPopupScene


func getInstancePosition(container, instance):
	var snapPosition: Vector2
	var offset: float = 10
	var hasXOverflow: bool = false
	
	snapPosition = container.global_position
	snapPosition.x += container.size.x + offset
	
	var endXPosition = container.global_position.x + container.size.x + instance.get_child(0).size.x
	var screenWidth = get_viewport().get_visible_rect().size.x
	if endXPosition > (screenWidth - offset * 2):
		hasXOverflow = true
		#snapPosition.x -= (endXPosition - screenWidth + offset * 2)
		snapPosition.x = container.global_position.x - instance.get_child(0).size.x - offset
		
	var endYPosition = container.global_position.y + instance.get_child(0).size.y
	var screenHeight = get_viewport().get_visible_rect().size.y
	if endYPosition > (screenHeight - offset * 2):
		snapPosition.y -= (endYPosition - screenHeight) + offset * 2
		#if hasXOverflow:
			#snapPosition.y -= (instance.get_child(0).size.y + offset * 2)
		#else:
			#snapPosition.y -= (endYPosition - screenHeight) + offset * 2
	
	return snapPosition


func closeUIOverlay(overlayInstance):
	AnimationsS.fadeWidth(overlayInstance.get_child(0), 0, fadeTimeOverlay)
	await get_tree().create_timer(fadeTimeOverlay).timeout
	overlayInstance.queue_free()
	currentOverlayScene = null


func closeUILoadingScreen(sceneInstance):
	AnimationsS.fadeVisible(sceneInstance, 0, fadeTimeLoadingScreen)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentLoadingScene = null


func closeUIPopup():
	currentPopupScene = null
	AnimationsS.fadeHeight(popupInstance, 0, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	if !currentPopupScene:
		popupInstance.visible = false


func closeUITooltip():
	currentTooltipScene = null
	AnimationsS.fadeHeight(tooltipInstance, 0, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	if !currentTooltipScene:
		tooltipInstance.visible = false


func closeUIScene(sceneInstance):
	playerScene.atExit = false
	playerScene.atTransportNode = false
	if currentUIScenes.size() == 1:
		playerScene.isInUIScene = false
		closeUIBlocker(currentBlockerScene)
	else:
		currentBlockerScene.z_index = currentUIScenes[currentUIScenes.size() - 2].z_index - 1
	AnimationsS.fadeHeight(sceneInstance, 0, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
	currentUIScenes.remove_at(currentUIScenes.find(sceneInstance))


func closeUIBlocker(sceneInstance):
	sceneInstance.queue_free()
	currentBlockerScene = null


func closeAllUIScenes():
	playerScene.isInUIScene = false
	playerScene.atExit = false
	playerScene.atTransportNode = false
	for UIScene in currentUIScenes:
		closeUIScene(UIScene)
	currentUIScenes.clear()
	if currentBlockerScene:
		closeUIBlocker(currentBlockerScene)
