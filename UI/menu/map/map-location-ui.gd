extends Control


@export var locationResource: MapLocation

@onready var game: Node2D = get_tree().get_root().get_node("Game")
@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var typeContainer: TextureRect = get_node("VBoxContainer/PanelContainer/TextureRect")
@onready var attributeContainer: HBoxContainer = get_node("VBoxContainer/HBoxContainer")
@onready var button: Button = get_node("VBoxContainer/PanelContainer/Button")

var canBeVisited: bool = false


func _ready():
	if !locationResource:
		queue_free()
		return
	
	setType()
	setAttributes()


func setType():
	var texture: Texture
	match locationResource.locationType:
		Enums.locationType.SETTLEMENT:
			texture = preload("res://assets/UI/icons/locations/Settlement.png")
		Enums.locationType.RUINS:
			texture = preload("res://assets/UI/icons/locations/Ruins.png")
		Enums.locationType.MYSTERY:
			texture = preload("res://assets/UI/icons/locations/Mystery.png")
		Enums.locationType.RETREAT:
			texture = preload("res://assets/UI/icons/locations/Retreat.png")
	typeContainer.texture = texture


func setAttributes():
	for attribute in locationResource.attributes:
		var attributeScene = preload("res://UI/menu/map/map-location-icon-ui.tscn").instantiate()
		attributeContainer.add_child(attributeScene)
		var texture: Texture
		match attribute:
			Enums.locationAttribute.DARKNESS:
				texture = preload("res://assets/UI/icons/locations/Darkness.png")
			Enums.locationAttribute.EXPOSURE:
				texture = preload("res://assets/UI/icons/locations/Exposure.png")
			Enums.locationAttribute.INFESTATION:
				texture = preload("res://assets/UI/icons/locations/Infestation.png")
			Enums.locationAttribute.COLLAPSE_RISK:
				texture = preload("res://assets/UI/icons/locations/Collapse Risk.png")
		attributeScene.setup(texture)


func _on_button_mouse_entered():
	UILoaderS.loadUIPopup(button, locationResource, true)
	if buttonActive():
		AnimationsS.setSize(self, 1.3, 0.15)


func _on_button_mouse_exited():
	UILoaderS.closeUIPopup()
	if buttonActive():
		AnimationsS.setSize(self, 1, 0.15)


func _on_button_pressed():
	if buttonActive():
		playerScene.atExit = false
		playerScene.isInCave = true
		var pathwayObject = findPathway(LocationLoaderS.currentLocation, locationResource.location)
		setupCaveGeneration(pathwayObject.PW, pathwayObject.FD, pathwayObject.TD)


func buttonActive():
	return playerScene.atExit && locationResource.location != LocationLoaderS.currentLocation && canBeVisited


func findPathway(source: int, destination: int):
	var allPathways = get_parent().get_parent().get_child(1).get_children()
	var foundPathway
	var fromDirection
	var toDirection
	for pathwayInstance in allPathways:
		if pathwayInstance.pathwayResource:
			if pathwayInstance.pathwayResource.locationFrom == source && \
				pathwayInstance.pathwayResource.locationTo == destination:
				foundPathway = pathwayInstance
				fromDirection = foundPathway.pathwayResource.travelDirections[0]
				toDirection = foundPathway.pathwayResource.travelDirections[1]
			if pathwayInstance.pathwayResource.locationTo == source && \
				pathwayInstance.pathwayResource.locationFrom == destination:
				foundPathway = pathwayInstance
				fromDirection = foundPathway.pathwayResource.travelDirections[1]
				toDirection = foundPathway.pathwayResource.travelDirections[0]
	
	return { "PW": foundPathway, "FD": fromDirection, "TD": toDirection }


func setupCaveGeneration(foundPathway, fromDirection, toDirection):
	LocationLoaderS.nextLocation = locationResource.location
	LocationLoaderS.caveGenerator.iterations = foundPathway.pathwayResource.iterations
	LocationLoaderS.caveGenerator.initialDirection = fromDirection
	LocationLoaderS.caveGenerator.availableDirections = foundPathway.pathwayResource.travelDirections
	LocationLoaderS.currentFromDirection = fromDirection
	LocationLoaderS.currentToDirection = toDirection
	LocationLoaderS.currentTier = foundPathway.pathwayResource.tier
	LocationLoaderS.loadCave()


func getNameFromScene(scene: PackedScene):
	return scene.instantiate().name.to_lower()
