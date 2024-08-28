extends PanelContainer


@export var pathwayResource: MapPathway


func _ready():
	if !pathwayResource:
		queue_free()


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, pathwayResource)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()
