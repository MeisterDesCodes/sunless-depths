extends Control


@onready var inputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/InputResources")
@onready var outputResources: HBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint/OutputResources")
@onready var title: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer/Title")
@onready var description: Label = get_node("BlueprintPopup/MarginContainer/VBoxContainer/PanelContainer2/Description")
@onready var blueprintContainer: VBoxContainer = get_node("BlueprintPopup/MarginContainer/VBoxContainer/Blueprint")

var element
var showAdditionalInfo


func _ready():
	blueprintContainer.visible = false


func setup(_element, _showAdditionalInfo: bool):
	element = _element
	showAdditionalInfo = _showAdditionalInfo
	title.text = element.name
	description.text = element.description
	
	if showAdditionalInfo:
		match element.type:
			Enums.resourceType.BLUEPRINT:
				blueprintContainer.visible = true
				for resource in element.inputResources:
					var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
					inputResources.add_child(resourceIcon)
					resourceIcon.setup(resource, true, true)
					
				for resource in element.outputResources:
					var resourceIcon = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
					outputResources.add_child(resourceIcon)
					resourceIcon.setup(resource, true, false)


func update():
	for resource in inputResources.get_children():
		resource.get_parent().remove_child(resource)
	for resource in outputResources.get_children():
		resource.get_parent().remove_child(resource)
	
	setup(element, showAdditionalInfo)





