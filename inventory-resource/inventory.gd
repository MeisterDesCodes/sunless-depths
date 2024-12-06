extends Resource

class_name Inventory

signal updateInventory
signal createSlot
signal updateResources
signal updateHealth
signal updateOxygen

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
	
	handlePrimaryResources(tempResource, amount, true)


func removeResource(tempResource: InventoryResource, amount: int):
	var foundResourceSlots = resourceSlots.filter(func(slot): return slot.resource.name == tempResource.name)
	if !foundResourceSlots.is_empty():
		foundResourceSlots[0].amount -= amount
		if foundResourceSlots[0].amount <= 0:
			resourceSlots.remove_at(resourceSlots.find(foundResourceSlots[0]))
	
	updateResourceTypes()
	updateInventory.emit()
	
	handlePrimaryResources(tempResource, amount, false)


func handlePrimaryResources(resource: InventoryResource, _amount: int, isAdded: bool):
	var amount = _amount if isAdded else _amount * -1
	if resource == preload("res://inventory-resource/resources/material/primary/health.tres"):
		updateHealth.emit(amount)
	if resource == preload("res://inventory-resource/resources/material/primary/oxygen.tres"):
		updateOxygen.emit(amount)


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
	UtilsS.updateResourceSlotTypes(resourceSlots)
	updateResources.emit()


func getTotalWeight():
	var totalWeight = 0
	for slot in resourceSlots:
		totalWeight += slot.resource.weight * slot.amount
	return totalWeight







