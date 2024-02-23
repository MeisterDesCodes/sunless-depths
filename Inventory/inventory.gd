extends Resource

class_name Inventory

signal update

@export var assetSlots: Array[InventorySlot]


func addResource(tempResource: InventoryResource, amount: int):
	var foundAssetSlots = assetSlots.filter(func(slot): return slot.item == tempResource)
	if !foundAssetSlots.is_empty():
		foundAssetSlots[0].amount += amount
	else:
		var emptySlots = assetSlots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = tempResource
			emptySlots[0].amount = amount
		
	update.emit()
