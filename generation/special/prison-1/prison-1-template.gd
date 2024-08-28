extends Node2D


@onready var spawners = get_node("Map/EnvironmentalObjects/Spawners")
@onready var gateEntry = get_node("Map/EnvironmentalObjects/Interactions/Functionality/GateEntry")
@onready var gateOperator = get_node("Map/EnvironmentalObjects/Interactions/Functionality/GateOperator")
@onready var arenaOperator = get_node("Map/EnvironmentalObjects/Interactions/Functionality/ArenaOperator")


func _ready():
	gateOperator.gate = gateEntry
	arenaOperator.spawners = spawners
	arenaOperator.enemiesDefeated.connect(openGate)


func openGate():
	gateEntry.openGate()
