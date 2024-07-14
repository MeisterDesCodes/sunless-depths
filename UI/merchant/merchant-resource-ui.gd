extends PanelContainer


signal purchasedResourcesUpdate

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var texture: TextureRect = get_node("MarginContainer/HBoxContainer/HBoxContainer/Texture")
@onready var description: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer/Name")
@onready var cost: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer2/Cost")
@onready var purchaseAmount: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer3/PurchaseAmount")
@onready var inventoryAmount: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer4/InventoryAmount")

var resource: InventoryResource
var selectedAmount = 0
var merchantMode = Enums.merchantMode.BUY
var priceModifier: float = 1


func setup(_resource: InventoryResource, _merchantMode: Enums.merchantMode, _priceModifier: float):
	resource = _resource
	merchantMode = _merchantMode
	priceModifier = _priceModifier
	texture.texture = resource.texture
	description.text = resource.name
	UtilsS.updateResourceType(resource)
	cost.text = str(calculateResourceCost())
	updatePurchaseAmount()
	updateInventoryAmount()


func calculateResourceCost():
	var rarityModifier: float = 1
	match resource.rarity:
		Enums.resourceRarity.UNCOMMON:
			rarityModifier = 1.5
		Enums.resourceRarity.RARE:
			rarityModifier = 2.25
		Enums.resourceRarity.EPIC:
			rarityModifier = 3.5
		Enums.resourceRarity.LEGENDARY:
			rarityModifier = 5.5
	
	var baseCost: float
	match resource.type:
		Enums.resourceType.MATERIAL:
			baseCost = 10
		Enums.resourceType.CONSUMABLE:
			baseCost = 35
		Enums.resourceType.BLUEPRINT:
			baseCost = 75
		Enums.resourceType.AMMUNITION:
			baseCost = 5
		Enums.resourceType.EQUIPMENT:
			baseCost = 125
		Enums.resourceType.WEAPON:
			baseCost = 150
	
	var sellModifier = 1 if merchantMode == Enums.merchantMode.BUY else 0.65
	return round(baseCost * rarityModifier * sellModifier * priceModifier)


func reset():
	selectedAmount = 0
	inventoryAmount.text = str(playerScene.inventory.getResourceAmount(resource))
	updatePurchaseAmount()
	updateInventoryAmount()


func updatePurchaseAmount():
	purchaseAmount.text = str(selectedAmount)
	if selectedAmount < 10:
		purchaseAmount.text = "0" + purchaseAmount.text
	purchasedResourcesUpdate.emit()


func updateInventoryAmount():
	if merchantMode == Enums.merchantMode.BUY:
		inventoryAmount.get_parent().get_child(0).texture = null
		inventoryAmount.text = ""
	else:
		inventoryAmount.text = str(playerScene.inventory.getResourceAmount(resource))


func calculateTotalCost():
	return selectedAmount * int(cost.text)


func _on_less_button_pressed():
	if selectedAmount > 0:
		selectedAmount -= 1
		updatePurchaseAmount()


func _on_more_button_pressed():
	if selectedAmount > 0&& resource.type == Enums.resourceType.WEAPON:
		return
	
	if selectedAmount < 99 && (merchantMode == Enums.merchantMode.BUY || selectedAmount < playerScene.inventory.getResourceAmount(resource)):
		selectedAmount += 1
		updatePurchaseAmount()


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, resource, true)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()









