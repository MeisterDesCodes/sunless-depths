extends PanelContainer


@onready var resourceContainer = get_node("MarginContainer/Resource")


func setup(requirement: ChoiceResource, showLabel: bool):
	resourceContainer.texture = requirement.resource.texture
	if showLabel:
		$"NinePatchRect/Amount".text = str(requirement.amount)
