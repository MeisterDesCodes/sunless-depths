extends Node2D


@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var caveGenerator = get_node("NavigationRegion2D/CaveGenerator")
@onready var player = get_node("Entities/Player")


func _ready():
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	caveGenerator.generateCave()
	navigationRegion.bake_navigation_polygon()
	

func spawnPlayer(_position: Vector2):
	player.global_position = _position
