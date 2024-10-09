extends Resource

class_name Inventory

signal updateInventory
signal createSlot

@export var resourceSlots: Array[InventorySlot]


func addResource(tempResource: InventoryResource, amount: int):
	var foundAssetSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundAssetSlots.is_empty() && foundAssetSlots[0].resource.type != Enums.resourceType.WEAPON \
		&& foundAssetSlots[0].resource.type != Enums.resourceType.EQUIPMENT:
		foundAssetSlots[0].amount += amount
	else:
		var newSlot = InventorySlot.new()
		newSlot.resource = tempResource
		newSlot.amount = amount
		resourceSlots.append(newSlot)
		createSlot.emit(newSlot)
	
	updateResourceTypes()
	updateInventory.emit()


func removeResource(tempResource: InventoryResource, amount: int):
	var foundResourceSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundResourceSlots.is_empty():
		foundResourceSlots[0].amount -= amount
		if foundResourceSlots[0].amount <= 0:
			resourceSlots.remove_at(resourceSlots.find(foundResourceSlots[0]))
	
	updateInventory.emit()


func hasResources(resourceContainers: Array):
	return resourceContainers.all(func(resourceContainer): return getResourceAmount(resourceContainer.resource) >= resourceContainer.amount)


func getResourceSlot(tempResource: InventoryResource):
	var foundResourceSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundResourceSlots.is_empty():
		return foundResourceSlots[0]
	else:
		return null


func getResource(tempResource: InventoryResource):
	var foundResourceSlot = getResourceSlot(tempResource)
	if foundResourceSlot:
		return foundResourceSlot.resource
	else:
		return null


func getResourceAmount(tempResource: InventoryResource):
	var foundResourceSlot = getResourceSlot(tempResource)
	if foundResourceSlot:
		return 1 if foundResourceSlot.resource is InventoryWeapon else foundResourceSlot.amount
	else:
		return 0


func updateResourceTypes():
	for resourceSlot in resourceSlots:
		UtilsS.updateResourceType(resourceSlot.resource)









