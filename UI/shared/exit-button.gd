extends Button


@export var scene: Control


func _on_mouse_entered():
	AnimationsS.changeColor(self, UtilsS.colorPrimaryBright, 0.15)
	AnimationsS.setSize(self, 1.05, 0.15)


func _on_mouse_exited():
	AnimationsS.changeColor(self, UtilsS.colorWhite, 0.15)
	AnimationsS.setSize(self, 1, 0.15)


func _on_pressed():
	UILoaderS.closeUIScene(scene)
