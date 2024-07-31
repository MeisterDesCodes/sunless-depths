extends PanelContainer


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var icon: TextureRect = get_node("Icon")
@onready var amount: Label = get_node("Amount")


func setup(_resource, _amount, _texture, showNumber: bool, isRequirement: bool):
	icon.texture = _texture
	if showNumber && !(_resource is InventoryWeapon) && !(_resource is InventoryEquipment):
		amount.text = str(_amount)
	if _resource && isRequirement:
		if _amount > playerScene.inventory.getResourceAmount(_resource):
			changeFrameColor(UtilsS.colorMissing)
		else:
			changeFrameColor(UtilsS.getRarityColor(_resource.rarity))


func changeIconColor(color: Color):
	icon.self_modulate = color


func changeFrameColor(color: Color):
	self_modulate = color
