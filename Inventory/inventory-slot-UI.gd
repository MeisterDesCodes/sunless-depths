extends PanelContainer


@onready var nameLabel: Label = $"NinePatchRect/MarginContainer/HBoxContainer/Name"
@onready var amountLabel: Label = $"NinePatchRect/MarginContainer/HBoxContainer/Amount"
@onready var icon: TextureRect = $"NinePatchRect/MarginContainer/HBoxContainer/Icon"


func update(slot: InventorySlot):
	if !slot.item:
		visible = false
	else:
		visible = true
		nameLabel.text = slot.item.name
		amountLabel.text = str(slot.amount)
		icon.texture = slot.item.texture
