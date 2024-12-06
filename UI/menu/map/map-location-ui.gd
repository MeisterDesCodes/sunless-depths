extends Control


@export var locationResource: MapLocation

@onready var game: Node2D = get_tree().get_root().get_node("GameController/Game")
@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var locationType: TextureRect = get_node("PanelContainer/TextureRect")
@onready var attributeContainer: HBoxContainer = get_node("AttributeContainer")
@onready var button: Button = get_node("PanelContainer/Button")
@onready var playerMarkerUI: Control = get_node("PlayerMarkerUI")
@onready var locationContainer: PanelContainer = get_node("PanelContainer")

var ringLevel: Enums.locationRingLevel
var canBeVisited: bool = false


func _ready():
	if !locationResource:
		queue_free()
		return
	
	playerMarkerUI.modulate = UtilsS.colorTransparent
	
	if !(locationResource.location in LocationLoaderS.exploredLocations):
		locationResource.description = "???"
	
	setType()
	setAttributes()


func updateLocation():
	match ringLevel:
		Enums.locationRingLevel.NONE:
			modulate = UtilsS.colorTransparent
			button.disable()
		Enums.locationRingLevel.OUTER:
			locationContainer.self_modulate = UtilsS.colorDisabled
			attributeContainer.visible = false
			locationType.visible = false
			button.disable(UtilsS.colorDisabled)
		Enums.locationRingLevel.INNER:
			var pathway = findPathway(LocationLoaderS.currentLocation.location, locationResource.location)
			if playerScene.atExit && playerScene.currentExitDirection == pathway.FD:
				button.select()
			else:
				button.disable()
		Enums.locationRingLevel.CURRENT:
			locationContainer.self_modulate = UtilsS.colorCommon
			button.disable()
			if !playerScene.isInCave:
				playerMarkerUI.modulate = UtilsS.colorWhite
	
	if playerScene.atTransportNode:
		if LocationLoaderS.currentLocation.location != locationResource.location && \
			locationResource.location in LocationLoaderS.transportableLocations:
			button.enable()
			button.select()
	
	if (playerScene.atExit && canBeVisited):
		button.enable()


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
	locationType.texture = texture


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
			Enums.locationAttribute.ROCK_SLIDES:
				texture = preload("res://assets/UI/icons/locations/Rock Slides.png")
		attributeScene.setup(texture)


func isOuterRing():
	return ringLevel == Enums.locationRingLevel.NONE || ringLevel == Enums.locationRingLevel.OUTER


func _on_button_mouse_entered():
	if !isOuterRing():
		UILoaderS.loadUIPopup(button, locationResource)


func _on_button_mouse_exited():
	UILoaderS.closeUIPopup()


func _on_button_pressed():
	if playerScene.atExit:
		var pathwayObject = findPathway(LocationLoaderS.currentLocation.location, locationResource.location)
		setupCaveGeneration(pathwayObject.PW, pathwayObject.FD, pathwayObject.TD)
		playerScene.atExit = false
		playerScene.isInCave = true
	else:
		LocationLoaderS.loadArea(locationResource)


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
	LocationLoaderS.nextLocation = locationResource
	LocationLoaderS.caveGenerator.iterations = foundPathway.pathwayResource.iterations
	LocationLoaderS.caveGenerator.tier = foundPathway.pathwayResource.tier
	LocationLoaderS.caveGenerator.initialDirection = fromDirection
	LocationLoaderS.caveGenerator.availableDirections = foundPathway.pathwayResource.travelDirections
	LocationLoaderS.currentFromDirection = fromDirection
	LocationLoaderS.currentToDirection = toDirection
	LocationLoaderS.currentTier = foundPathway.pathwayResource.tier
	LocationLoaderS.attributes = foundPathway.pathwayResource.attributes
	LocationLoaderS.caveGenerator.caveVariation = foundPathway.pathwayResource.caveVariation
	LocationLoaderS.loadCave(foundPathway.pathwayResource)


func getNameFromScene(scene: PackedScene):
	return scene.instantiate().name.to_lower()
