extends Node


@onready var game = get_tree().get_root().get_node("Game")
@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var caveGenerator = get_tree().get_root().get_node("Game/NavigationRegion2D/CaveGenerator")

var currentLocation: String
var nextLocation: String
var currentFromDirection: Enums.exitDirection
var currentToDirection: Enums.exitDirection
var currentTier: int

var visitedLocations: Array[String]


func loadArea(location: String):
	await startAreaTransition()
	removeCurrentCave()
	currentLocation = location
	nextLocation = ""
	visitedLocations.append(location)
	game.currentLocation.add_child(LocationLoaderS.getSceneFromName(location).instantiate())
	finishAreaTransition()


func loadCave():
	await startAreaTransition()
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	removeCurrentLocation()
	caveGenerator.generateCave()
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


func getSceneFromName(name: String):
	var allLocations: Array[PackedScene] = preload("res://UI/menu/map/resources/locations.tres").allLocations
	var filteredLocations = allLocations.filter(func(location): return name.to_lower() in location.instantiate().name.to_lower())
	return filteredLocations[0]
