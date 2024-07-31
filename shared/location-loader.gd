extends Node


@onready var game = get_tree().get_root().get_node("Game")
@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var caveGenerator = get_tree().get_root().get_node("Game/NavigationRegion2D/CaveGenerator")

var currentLocation: Enums.locations
var nextLocation: Enums.locations
var currentFromDirection: Enums.exitDirection
var currentToDirection: Enums.exitDirection
var currentTier: int

var visitedLocations: Array[Enums.locations]


func loadArea(location: Enums.locations):
	await startAreaTransition()
	removeCurrentCave()
	currentLocation = location
	nextLocation = -1
	visitedLocations.append(location)
	game.currentLocation.add_child(getSceneFromId(location).instantiate())
	finishAreaTransition()


func loadCave():
	await startAreaTransition()
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	removeCurrentLocation()
	caveGenerator.generateCave()
	
	#TODO Monitor
	await get_tree().process_frame
	
	game.navigationRegion.bake_navigation_polygon()
	finishAreaTransition()


func startAreaTransition():
	playerScene.isInLoadingScreen = true
	UILoaderS.loadLoadingScreen(preload("res://UI/shared/loading-screen.tscn"))
	await get_tree().create_timer(0.5).timeout
	return true


func finishAreaTransition():
	UILoaderS.closeAllUIScenes()
	await get_tree().create_timer(1).timeout
	UILoaderS.closeLoadingScreen(UILoaderS.currentLoadingScene)
	playerScene.isInLoadingScreen = false


func removeCurrentLocation():
	for child in game.currentLocation.get_children():
		game.currentLocation.remove_child(child)


func removeCurrentCave():
	for child in caveGenerator.get_child(0).get_children():
		caveGenerator.get_child(0).remove_child(child)


func spawnPlayer(_position: Vector2):
	game.playerScene.global_position = _position


func getSceneFromId(location: Enums.locations):
	var locationName = UtilsS.getEnumValue(Enums.locations, location).to_lower().replace(" ", "")
	var allLocations: Array[PackedScene] = preload("res://UI/menu/map/resources/locations.tres").allLocations
	var foundLocations = allLocations.filter(func(location): return location.instantiate().name.to_lower() == locationName)
	return foundLocations[0]
