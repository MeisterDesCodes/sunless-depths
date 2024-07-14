extends PanelContainer


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var icon: TextureRect = get_node("Icon")
@onready var amount: Label = get_node("Amount")


func setup(requirement, showLabel: bool, isRequirement: bool):
	icon.texture = requirement.resource.texture
	if showLabel:
		amount.text = str(requirement.amount)
	if isRequirement && requirement.amount > playerScene.inventory.getResourceAmount(requirement.resource):
		self_modulate = UtilsS.colorMissing
	else:
		self_modulate = UtilsS.getRarityColor(requirement.resource.rarity)
