extends PanelContainer


@onready var nameLabel: Label = $"NinePatchRect/MarginContainer/HBoxContainer/Name"
@onready var amountLabel: Label = $"NinePatchRect/MarginContainer/HBoxContainer/Amount"
@onready var icon: TextureRect = $"NinePatchRect/MarginContainer/HBoxContainer/Texture"


func update(slot: InventorySlot):
	nameLabel.text = slot.resource.name
	amountLabel.text = str(slot.amount)
	icon.texture = slot.resource.texture
