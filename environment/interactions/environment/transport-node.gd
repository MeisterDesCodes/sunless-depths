extends Node2D


@export var lifetime: int
@export var interactionCost: float
@export var repairCosts: Array[InventorySlot]

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var interaction = get_node("Interactions/InteractionComponent")
@onready var playerSpawner = get_node("PlayerSpawner")

@onready var brokenWall = preload("res://assets/environment/decorations/walls/tunnel/wall-metal-broken-1.png")
@onready var brokenMinecart = preload("res://assets/environment/decorations/walls/tunnel/minecart-broken.png")
@onready var brokenRail = preload("res://assets/environment/decorations/regular/mineshaft/rail-broken-2.png")
@onready var repairedWall = preload("res://assets/environment/decorations/walls/tunnel/wall-metal-2.png")
@onready var repairedMinecart = preload("res://assets/environment/decorations/walls/tunnel/minecart.png")
@onready var repairedRail = preload("res://assets/environment/decorations/regular/mineshaft/rail-straight.png")

@onready var wallReplace1 = get_node("Walls/ReplaceWall")
@onready var wallReplace2 = get_node("Walls/ReplaceWall2")
@onready var wallDelete1 = get_node("Walls/DeleteWall")
@onready var wallDelete2 = get_node("Walls/DeleteWall2")
@onready var wallDelete3 = get_node("Walls/DeleteWall3")
@onready var wallDelete4 = get_node("Walls/DeleteWall4")
@onready var wallDelete5 = get_node("Walls/DeleteWall5")
@onready var minecartReplace = get_node("Decorations/MinecartReplace")
@onready var railReplace1 = get_node("Decorations/RailReplace")
@onready var railReplace2 = get_node("Decorations/RailReplace2")


var isBroken: bool = true


func _ready():
	interaction.onInteract.connect(interact)
	
	if !LocationLoaderS.currentLocation:
		return
	
	if LocationLoaderS.currentLocation.location in LocationLoaderS.transportableLocations:
		isBroken = false
	else:
		wallReplace1.texture = brokenWall
		wallReplace2.texture = brokenWall
		wallDelete1.visible = false
		wallDelete2.visible = false
		wallDelete3.visible = false
		wallDelete4.visible = false
		wallDelete5.visible = false
		minecartReplace.texture = brokenMinecart
		minecartReplace.rotation = 200
		railReplace1.texture = brokenRail
		railReplace2.texture = brokenRail


func interact(body):
	if isBroken && playerScene.inventory.hasResources(repairCosts):
		for repairCost in repairCosts:
			playerScene.inventory.removeResource(repairCost.resource, repairCost.amount)
		
		isBroken = false
		LocationLoaderS.transportableLocations.append(LocationLoaderS.currentLocation.location)

		wallReplace1.texture = repairedWall
		wallReplace2.texture = repairedWall
		wallDelete1.visible = true
		wallDelete2.visible = true
		wallDelete3.visible = true
		wallDelete4.visible = true
		wallDelete5.visible = true
		minecartReplace.texture = repairedMinecart
		minecartReplace.rotation = 90
		railReplace1.texture = repairedRail
		railReplace2.texture = repairedRail
	else:
		playerScene.atTransportNode = true
		var menuScene = UILoaderS.loadUIScene(preload("res://UI/menu/menu-ui.tscn"))
		menuScene._on_map_pressed()
