extends Control


@export var type: Enums.locationType
@export var attributes: Array[Enums.locationAttribute]
@export var location: String

@onready var game: Node2D = get_tree().get_root().get_node("Game")
@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("Game/Entities/Player")
@onready var typeContainer: TextureRect = get_node("VBoxContainer/PanelContainer/TextureRect")
@onready var attributeContainer: HBoxContainer = get_node("VBoxContainer/HBoxContainer")
@onready var allPathways = self.get_parent().get_parent().get_child(1).get_children()

var canBeVisited: bool = false


func _ready():
	setType()
	setAttributes()


func setType():
	var texture: Texture
	match type:
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
	for attribute in attributes:
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
			Enums.locationAttribute.DANGER:
				texture = preload("res://assets/UI/icons/locations/Danger.png")
		attributeScene.setup(texture)


func _on_button_mouse_entered():
	if buttonActive():
		AnimationsS.setSize(self, 1.3, 0.15)


func _on_button_mouse_exited():
	if buttonActive():
		AnimationsS.setSize(self, 1, 0.15)


func _on_button_pressed():
	if buttonActive():
		playerScene.atExit = false
		var pathwayObject = findPathway(LocationLoaderS.currentLocation, location)
		setupCaveGeneration(pathwayObject.PW, pathwayObject.FD, pathwayObject.TD)


func buttonActive():
	return playerScene.atExit && location != LocationLoaderS.currentLocation && canBeVisited


func findPathway(source: String, destination: String):
	var foundPathway
	var fromDirection
	var toDirection
	for pathway in allPathways:
		if pathway.locationFrom.to_lower() == source.to_lower() && \
			pathway.locationTo.to_lower() == destination.to_lower():
			foundPathway = pathway
			fromDirection = foundPathway.travelDirections[0]
			toDirection = foundPathway.travelDirections[1]
		if pathway.locationTo.to_lower() == source.to_lower() && \
			pathway.locationFrom.to_lower() == destination.to_lower():
			foundPathway = pathway
			fromDirection = foundPathway.travelDirections[1]
			toDirection = foundPathway.travelDirections[0]
	
	return { "PW": foundPathway, "FD": fromDirection, "TD": toDirection }


func setupCaveGeneration(foundPathway, fromDirection, toDirection):
	LocationLoaderS.nextLocation = location
	LocationLoaderS.caveGenerator.iterations = foundPathway.iterations
	LocationLoaderS.caveGenerator.initialDirection = fromDirection
	LocationLoaderS.caveGenerator.availableDirections = foundPathway.travelDirections
	LocationLoaderS.currentFromDirection = fromDirection
	LocationLoaderS.currentToDirection = toDirection
	LocationLoaderS.currentTier = foundPathway.tier
	LocationLoaderS.loadCave()


func getNameFromScene(scene: PackedScene):
	return scene.instantiate().name.to_lower()







