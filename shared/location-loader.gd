extends Node


@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var caveGenerator = get_tree().get_root().get_node("GameController/Game/NavigationRegion2D/CaveGenerator")

var currentLocation: MapLocation
var nextLocation: MapLocation
var currentPathway: MapPathway
var currentFromDirection: Enums.exitDirection
var currentToDirection: Enums.exitDirection
var currentTier: int
var attributes: Array[Enums.locationAttribute]
var lightModifier: int = 0

var visitedLocations: Array[Enums.locations]
var exploredLocations: Array[Enums.locations]
var transportableLocations: Array[Enums.locations]
var visitedRooms: Array[int]

var currentInteraction: Node2D

var currentCave: Node2D


func loadArea(location: MapLocation, showLocationHeader: bool = true):
	await startAreaTransition()
	removeCurrentLocation()
	removeCurrentCave()
	removeAttributes()
	setupAttributes(true)
	currentLocation = location
	visitedLocations.append(location)
	game.currentLocation.add_child(getSceneFromId(location.location).instantiate())
	game.soundComponent.playSettlementAmbient(currentLocation)
	
	#TODO Monitor chase not working
	await get_tree().process_frame
	
	game.navigationRegion.bake_navigation_polygon()
	finishAreaTransition()
	
	if showLocationHeader:
		await UtilsS.createTimer(1.5)
		var UIHeader = UILoaderS.loadUIOverlay(preload("res://UI/shared/location-header.tscn"))
		UIHeader.setup(UtilsS.getEnumValue(Enums.locations, currentLocation.location))


func loadCave(pathway: MapPathway):
	await startAreaTransition()
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	removeCurrentCave()
	removeCurrentLocation()
	caveGenerator.generateCave()
	setupAttributes(false)
	currentPathway = pathway
	game.soundComponent.playCaveAmbient(currentPathway)
	
	#TODO Monitor chase not working
	await get_tree().process_frame
	
	game.navigationRegion.bake_navigation_polygon()
	finishAreaTransition()
	
	await UtilsS.createTimer(1.5)
	var UIHeader = UILoaderS.loadUIOverlay(preload("res://UI/shared/location-header.tscn"))
	UIHeader.setup("Tunnel towards: " + UtilsS.getEnumValue(Enums.locations, nextLocation.location))


func startAreaTransition():
	playerScene.isInLoadingScreen = true
	UILoaderS.loadUILoadingScreen(preload("res://UI/shared/loading-screen.tscn"))
	await UtilsS.createTimer(0.5)
	return true


func finishAreaTransition():
	UILoaderS.closeAllUIScenes()
	await UtilsS.createTimer(1)
	UILoaderS.closeUILoadingScreen(UILoaderS.currentLoadingScene)
	playerScene.isInLoadingScreen = false


func removeCurrentLocation():
	for child in game.currentLocation.get_children():
		game.currentLocation.remove_child(child)


func removeCurrentCave():
	for child in caveGenerator.get_child(0).get_children():
		caveGenerator.get_child(0).remove_child(child)
	
	UtilsS.removeEntitiesFromScene(caveGenerator.get_child(1))


func spawnPlayer(_position: Vector2):
	game.playerScene.global_position = _position


func getSceneFromId(location: Enums.locations):
	var locationName = UtilsS.getEnumValue(Enums.locations, location).to_lower().replace(" ", "")
	var allLocations: Array[PackedScene] = preload("res://UI/menu/map/resources/locations.tres").allLocations
	var foundLocations = allLocations.filter(func(location): return location.instantiate().name.to_lower() == locationName)
	return foundLocations[0]


func setupAttributes(isLocation: bool):
	for attribute in attributes:
		match attribute:
			Enums.locationAttribute.DARKNESS:
				lightModifier -= 2
				game.canvasModulate.color = UtilsS.colorBlack
		
	if isLocation:
		match currentLocation.locationType:
			Enums.locationType.SETTLEMENT:
				game.canvasModulate.color = UtilsS.colorGray


func removeAttributes():
	LocationLoaderS.lightModifier = 0
	game.canvasModulate.color = UtilsS.colorCanvasModulate


func getBasicCave(_cave: Node2D):
	var cave = Node2D.new()
	for _room in _cave.get_children():
		var room = _room.duplicate()
		cave.add_child(room)
			
		if "id" in room:
			room.id = _room.id
			room.removeObjects()
			
	return cave


func getCavePosition(cave: Node2D):
	var left: int = 0
	var top: int = 0
	for room in cave.get_children():
		var x = room.global_position.x
		var y = room.global_position.y
		if x < left:
			left = x
		if y < top:
			top = y
	
	return Vector2(-left, -top)


