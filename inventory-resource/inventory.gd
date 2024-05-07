extends Resource

class_name Inventory

signal update

@export var resourceSlots: Array[InventorySlot]


func addResource(tempResource: InventoryResource, amount: int):
	var foundAssetSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundAssetSlots.is_empty() && foundAssetSlots[0].resource.type != Enums.resourceType.WEAPON:
		foundAssetSlots[0].amount += amount
	else:
		var newSlot = InventorySlot.new()
		newSlot.resource = tempResource
		newSlot.amount = amount
		resourceSlots.append(newSlot)
	
	updateInventory()
	update.emit()


func removeResource(tempResource: InventoryResource, amount: int):
	var foundResourceSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundResourceSlots.is_empty():
		foundResourceSlots[0].amount -= amount
		if foundResourceSlots[0].amount <= 0:
			resourceSlots.remove_at(resourceSlots.find(foundResourceSlots[0], 0))
	
	update.emit()


func hasResources(resourceContainers: Array):
	return resourceContainers.all(func(resourceContainer): return getResourceAmount(resourceContainer.resource) >= resourceContainer.amount)


func getResourceAmount(tempResource: InventoryResource):
	var foundResourceSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundResourceSlots.is_empty():
		var resourceSlot = foundResourceSlots[0]
		return 1 if resourceSlot.resource is Weapon else resourceSlot.amount
	else:
		return 0


func updateInventory():
	for resourceSlot in resourceSlots:
		UtilsS.updateResource(resourceSlot.resource)


