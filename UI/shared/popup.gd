extends Control


@onready var inputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/InputResources")
@onready var outputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/OutputResources")
@onready var title: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer/Title")
@onready var description: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer2/Description")


func setup(element):
	title.text = element.name
	description.text = element.description
	
	match element.type:
		Enums.resourceType.BLUEPRINT:
			for resource in element.inputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				inputResources.add_child(resourceIcon)
				resourceIcon.setup(resource, true, true)
				
			for resource in element.outputResources:
				var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
				outputResources.add_child(resourceIcon)
				resourceIcon.setup(resource, true, false)
