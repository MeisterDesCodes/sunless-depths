extends Control

@onready var popupMain = get_node("VBoxContainer/PopupMain")
@onready var popupSecondary = get_node("VBoxContainer/PopupSecondary")


func _ready():
	visible = false
	popupSecondary.self_modulate = UtilsS.colorDisabled


func setup(element):
	popupMain.setup(element)
	if element is InventoryBlueprint:
		popupSecondary.visible = true
		UtilsS.updateResourceType(element.outputResources[0].resource)
		popupSecondary.setup(element.outputResources[0].resource)
	else:
		popupSecondary.visible = false
