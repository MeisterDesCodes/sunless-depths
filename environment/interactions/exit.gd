extends Node2D


@export var lifetime: int

@onready var interactionComponent = get_node("InteractionConponent")


func _ready():
	interactionComponent.onEnter.connect(enter)


func enter(body):
	var scene = UILoaderS.loadUIScene(preload("res://UI/inventory/menu-ui.tscn"))
	scene._on_map_pressed()
