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
		match requirement.resource.rarity:
			Enums.resourceRarity.PRIMARY:
				resourceContainer.self_modulate = UtilsS.colorPrimary
			Enums.resourceRarity.COMMON:
				resourceContainer.self_modulate = UtilsS.colorCommon
			Enums.resourceRarity.UNCOMMON:
				resourceContainer.self_modulate = UtilsS.colorUncommon
			Enums.resourceRarity.RARE:
				resourceContainer.self_modulate = UtilsS.colorRare
			Enums.resourceRarity.EPIC:
				resourceContainer.self_modulate = UtilsS.colorEpic
			Enums.resourceRarity.LEGENDARY:
				resourceContainer.self_modulate = UtilsS.colorLegendary
