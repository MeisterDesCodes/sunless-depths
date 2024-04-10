extends Node


class_name UILoader


func loadUIScene(scene: PackedScene):
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var sceneInstance = scene.instantiate()
	canvasLayer.add_child(sceneInstance)
	return sceneInstance


func isSceneOpen(scene: PackedScene):
	var sceneInstance = scene.instantiate()
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	return !canvasLayer.get_children().all(func(UIScene): return UIScene.name != sceneInstance.name)


func closeUIScene(scene: PackedScene):
	var sceneInstance = scene.instantiate()
	var canvasLayer: Control = get_tree().get_root().get_node("Game/CanvasLayer/UIControl")
	var foundScenes = canvasLayer.get_children().filter(func(UIScene): return UIScene.name == sceneInstance.name)
	if !foundScenes.is_empty():
		foundScenes[0].queue_free()
