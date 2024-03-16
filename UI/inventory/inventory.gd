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


func removeResource(tempResource: InventoryResource, amount: int):
	var foundAssetSlots = assetSlots.filter(func(slot): return slot.item == tempResource)
	if !foundAssetSlots.is_empty():
		foundAssetSlots[0].amount -= amount
		if foundAssetSlots[0].amount <= 0:
			foundAssetSlots[0].item = null
	
	update.emit()

func getResource(tempResource: InventoryResource):
	var foundAssetSlots = assetSlots.filter(func(slot): return slot.item == tempResource)
	if !foundAssetSlots.is_empty():
		return foundAssetSlots[0].amount
	else:
		return 0









