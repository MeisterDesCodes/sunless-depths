extends Control


@onready var game = get_tree().get_root().get_node("Game")
@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var scrollContainer: ScrollContainer = get_node("PanelContainer/MarginContainer/ScrollContainer")
@onready var caveContainer: Node2D = get_node("PanelContainer/MarginContainer/ScrollContainer/CaveContainer")

var playerMarker = preload("res://UI/menu/map/player-marker-ui.tscn").instantiate()

var mouseInside: bool = false
var cave

var baseZoom: float = 0.25
var zoomAmount: float = 0.02
var maxZoomLevels: int = 20
var currentZoomLevel: int = 5
var dragging: bool = false
var startingPosition: Vector2 = Vector2.ZERO
var lastPosition: Vector2 = Vector2.ZERO


func _ready():
	if !playerScene.isInCave && !(LocationLoaderS.currentLocation.location in LocationLoaderS.exploredLocations):
		return
	
	cave = LocationLoaderS.getBasicCave(LocationLoaderS.currentCave if playerScene.isInCave else game.currentLocation)
	caveContainer.global_position = LocationLoaderS.getCavePosition(cave) * caveContainer.scale
	caveContainer.add_child(cave)
	caveContainer.add_child(playerMarker)
	setupPlayerMarker()
	zoomMap()
	setupMapLocation()
	
	if playerScene.isInCave:
		for room in cave.get_children():
			if !(room.id in LocationLoaderS.visitedRooms):
				room.queue_free()


func setupPlayerMarker():
	playerMarker.position = (playerScene.global_position - Vector2(playerMarker.size.x * 1.5, playerMarker.size.y * 1.5)) * cave.scale.x
	playerMarker.scale = Vector2(3, 3)
	playerMarker.z_index = 3


func setupMapLocation():
	caveContainer.position = -(playerMarker.position - Vector2(2000, 800)) * caveContainer.scale
	lastPosition = caveContainer.position


func _process(delta):
	if Input.is_action_just_pressed("switch-up"):
		if currentZoomLevel < maxZoomLevels:
			currentZoomLevel += 1
			#caveContainer.position += Vector2(0, 25 * caveContainer.scale.x)
			zoomMap()
	
	if Input.is_action_just_pressed("switch-down"):
		if currentZoomLevel > 0:
			currentZoomLevel -= 1
			#caveContainer.position += Vector2(0, -25 * caveContainer.scale.x)
			zoomMap()


func zoomMap():
	var zoom: float = baseZoom + (currentZoomLevel - 5) * zoomAmount
	caveContainer.scale = Vector2(zoom, zoom)
	lastPosition = caveContainer.position


func _on_button_mouse_entered():
		mouseInside = true


func _on_button_mouse_exited():
		mouseInside = false


func _on_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			startingPosition = get_local_mouse_position()
		else:
			dragging = false
			startingPosition = Vector2.ZERO
			lastPosition = caveContainer.position
	
	if event is InputEventMouseMotion:
		if dragging:
			caveContainer.position = (get_local_mouse_position() - startingPosition) + lastPosition
