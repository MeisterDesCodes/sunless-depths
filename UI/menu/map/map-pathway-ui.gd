extends PanelContainer


@export var pathwayResource: MapPathway

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var playerMarker: Control = get_node("PlayerMarkerUI")


func _ready():
	if !pathwayResource:
		queue_free()
	
	if !playerScene.isInCave || !LocationLoaderS.currentPathway || LocationLoaderS.currentPathway != pathwayResource:
		playerMarker.queue_free()


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, pathwayResource)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()
