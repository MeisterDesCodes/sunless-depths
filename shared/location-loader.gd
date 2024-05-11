extends Node


@onready var game = get_tree().get_root().get_node("Game")
@onready var caveGenerator = get_tree().get_root().get_node("Game/NavigationRegion2D/CaveGenerator")

var currentLocation: String
var nextLocation: String
var currentFromDirection: Enums.exitDirection
var currentToDirection: Enums.exitDirection

var visitedLocations: Array[String]


func loadArea(location: String):
	removeCurrentCave()
	currentLocation = location
	nextLocation = ""
	visitedLocations.append(location)
	game.currentLocation.add_child(LocationLoaderS.getSceneFromName(location).instantiate())


func removeCurrentLocation():
	for child in game.currentLocation.get_children():
		game.currentLocation.remove_child(child)


func removeCurrentCave():
	for child in caveGenerator.get_child(0).get_children():
		caveGenerator.get_child(0).remove_child(child)


func generateCave():
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	removeCurrentLocation()
	caveGenerator.generateCave()
	game.navigationRegion.bake_navigation_polygon()


func spawnPlayer(_position: Vector2):
	game.playerScene.global_position = _position


func getSceneFromName(name: String):
	var allLocations: Array[PackedScene] = load("res://UI/menu/map/resources/locations.tres").allLocations
	var filteredLocations = allLocations.filter(func(location): return name.to_lower() in location.instantiate().name.to_lower())
	return filteredLocations[0]
