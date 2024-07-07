extends Node2D


@onready var playerScene = get_node("Entities/Player")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var currentLocation = get_node("CurrentLocation")


func _ready():
	visible = false
	LocationLoaderS.removeCurrentLocation()
	LocationLoaderS.loadArea("Settle")
	visible = true
