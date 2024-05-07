extends Node


class_name UILoader

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")

var fadeTime: float = 0.1


func loadUIScene(scene: PackedScene):
	playerScene.isInDialog = true
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	AnimationsS.fadeInHeight(sceneInstance, fadeTime)
	return sceneInstance


func loadUILabel(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	return sceneInstance


func loadUIPopup(container, element, showAdditionalInfo: bool):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var popupInstance = preload("res://UI/shared/popup.tscn").instantiate()
	canvasLayer.add_child(popupInstance)
	popupInstance.setup(element, showAdditionalInfo)
	
	var snapPosition: Vector2
	var offsetX: float = 30
	var offsetY: float = 50
	if container.global_position.x + popupInstance.get_child(0).size.x <= get_viewport().get_visible_rect().size.x:
		snapPosition = container.global_position + Vector2(container.size.x + offsetX, 0)
	else:
		snapPosition = container.global_position - Vector2(popupInstance.get_child(0).size.x + offsetX, 0)
	
	var diff: float = container.global_position.y + popupInstance.get_child(0).size.y - get_viewport().get_visible_rect().size.y
	if diff + offsetY > 0:
		snapPosition -= Vector2(0, diff + offsetY)
	
	popupInstance.global_position = snapPosition
	
	AnimationsS.fadeInHeight(popupInstance, fadeTime)
	return popupInstance


func closeUILabel(popupInstance):
	popupInstance.queue_free()


func closeUIPopup(popupInstance):
	AnimationsS.fadeOutHeight(popupInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	popupInstance.queue_free()


func closeUIScene(sceneInstance):
	playerScene.isInDialog = false
	AnimationsS.fadeOutHeight(sceneInstance, fadeTime)
	await get_tree().create_timer(fadeTime).timeout
	sceneInstance.queue_free()
