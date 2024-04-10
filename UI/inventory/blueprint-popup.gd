extends PanelContainer


@onready var inputResources: HBoxContainer = get_node("MarginContainer/VBoxContainer/InputResources")
@onready var outputResources: HBoxContainer = get_node("MarginContainer/VBoxContainer/OutputResources")


func _ready():
	visible = false


func setup(blueprint: InventoryBlueprint, parentPosition: Vector2):
	for resourceContainer in inputResources.get_children():
		resourceContainer.queue_free()
	for resourceContainer in outputResources.get_children():
		resourceContainer.queue_free()
	
	for resource in blueprint.inputResources:
		var requirementScene = preload("res://UI/dialogs/dialog-choice-requirement-ui.tscn").instantiate()
		inputResources.add_child(requirementScene)
		requirementScene.setup(resource, true, true)
		
	for resource in blueprint.outputResources:
		var requirementScene = preload("res://UI/dialogs/dialog-choice-requirement-ui.tscn").instantiate()
		outputResources.add_child(requirementScene)
		requirementScene.setup(resource, true, false)
		
	global_position = parentPosition
