extends Button


@export var scene: Control

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")


func _on_mouse_entered():
	if !disabled:
		AnimationsS.changeColor(self, UtilsS.colorPrimaryBright, 0.15)
		AnimationsS.setSize(self, 1.05, 0.15)
		playerScene.soundComponent.onHover()


func _on_mouse_exited():
	if !disabled:
		AnimationsS.changeColor(self, UtilsS.colorWhite, 0.15)
		AnimationsS.setSize(self, 1, 0.15)


func _on_pressed():
	playerScene.soundComponent.onClick()
	UILoaderS.closeUIScene(scene)
