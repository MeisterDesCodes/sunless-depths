extends PanelContainer


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var resource = get_node("MarginContainer/Resource")
@onready var resourceContainer = get_node("NinePatchRect")


func setup(requirement, showLabel: bool, isRequirement: bool):
	resource.texture = requirement.resource.texture
	if showLabel:
		$"NinePatchRect/Amount".text = str(requirement.amount)
	if isRequirement && requirement.amount > playerScene.inventory.getResourceAmount(requirement.resource):
		resourceContainer.self_modulate = UtilsS.colorMissing
	else:
		resourceContainer.self_modulate = UtilsS.getRarityColor(requirement.resource.rarity)
