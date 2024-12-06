extends PanelContainer


@export var pathwayResource: MapPathway

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var playerMarker: Control = get_node("PlayerMarkerUI")


func _ready():
	if !pathwayResource:
		queue_free()
	
	if pathwayResource.name == "":
		pathwayResource.name = "Pathway"
	if pathwayResource.description == "":
		pathwayResource.description = "Connects " + UtilsS.getEnumValue(Enums.locations, pathwayResource.locationFrom) \
			+ " and " + UtilsS.getEnumValue(Enums.locations, pathwayResource.locationTo)
	
	if !playerScene.isInCave || !LocationLoaderS.currentPathway || LocationLoaderS.currentPathway != pathwayResource:
		playerMarker.queue_free()


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, pathwayResource)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()
