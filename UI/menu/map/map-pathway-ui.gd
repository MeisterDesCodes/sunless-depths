extends PanelContainer


@export var pathwayResource: MapPathway


func _ready():
	if !pathwayResource:
		queue_free()


func _on_button_mouse_entered():
	UILoaderS.loadUIPopup(self, pathwayResource, true)


func _on_button_mouse_exited():
	UILoaderS.closeUIPopup()
