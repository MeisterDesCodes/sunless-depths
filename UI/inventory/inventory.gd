extends Resource

class_name Inventory

signal update

@export var assetSlots: Array[InventorySlot]


func addResource(tempResource: InventoryResource, amount: int):
	var foundAssetSlots = assetSlots.filter(func(slot): return slot.resource == tempResource)
	if !foundAssetSlots.is_empty():
		foundAssetSlots[0].amount += amount
	else:
		var newSlot = InventorySlot.new()
		newSlot.resource = tempResource
		newSlot.amount = amount
		assetSlots.append(newSlot)
	
	update.emit()


func removeResource(tempResource: InventoryResource, amount: int):
	var foundResourceSlots = assetSlots.filter(func(slot): return slot.resource == tempResource)
	if !foundResourceSlots.is_empty():
		foundResourceSlots[0].amount -= amount
		if foundResourceSlots[0].amount <= 0:
			assetSlots.remove_at(assetSlots.find(foundResourceSlots[0], 0))
	
	update.emit()


func hasResources(resourceContainers: Array):
	return resourceContainers.all(func(resourceContainer): return getResourceAmount(resourceContainer.resource) >= resourceContainer.amount)


func getResourceAmount(tempResource: InventoryResource):
	var foundResourceSlots = assetSlots.filter(func(slot): return slot.resource == tempResource)
	if !foundResourceSlots.is_empty():
		return foundResourceSlots[0].amount
	else:
		return 0









