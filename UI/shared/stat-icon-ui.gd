@tool
extends PanelContainer


@export var texture: Texture2D:
	set(value):
		texture = value
		$"Icon".texture = texture

@export var tooltip: String


func _on_mouse_entered():
	UILoaderS.loadUITooltip(self, tooltip)


func _on_mouse_exited():
	UILoaderS.closeUITooltip()
