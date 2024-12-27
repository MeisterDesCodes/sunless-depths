extends PanelContainer


signal purchasedResourcesUpdate

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var texture: TextureRect = get_node("MarginContainer/HBoxContainer/HBoxContainer/Texture")
@onready var description: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer/Name")
@onready var cost: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer2/Cost")
@onready var inventoryAmount: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer4/InventoryAmount")
@onready var purchaseAmount: Label = get_node("MarginContainer/HBoxContainer/HBoxContainer3/PanelContainer/PurchaseAmount")

var resource: InventoryResource
var selectedAmount: int = 0
var merchantMode: Enums.merchantMode = Enums.merchantMode.BUY
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
			baseCost = 8
		Enums.resourceType.CONSUMABLE:
			baseCost = 25
		Enums.resourceType.BLUEPRINT:
			baseCost = 125
		Enums.resourceType.AMMUNITION:
			baseCost = 2
		Enums.resourceType.EQUIPMENT:
			baseCost = 75
		Enums.resourceType.WEAPON:
			baseCost = 125
	
	var sellModifier = 1 if merchantMode == Enums.merchantMode.BUY else 0.5
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
	inventoryAmount.text = str(playerScene.inventory.getResourceAmount(resource))


func calculateTotalCost():
	return selectedAmount * int(cost.text)


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, resource)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()


func increaseAmount(amount: int):
	if selectedAmount > 0 && (resource.type == Enums.resourceType.WEAPON || resource.type == Enums.resourceType.EQUIPMENT):
		return
	
	selectedAmount += amount
	if merchantMode == Enums.merchantMode.BUY && selectedAmount > 99:
		selectedAmount = 99
	if merchantMode == Enums.merchantMode.SELL && selectedAmount > playerScene.inventory.getResourceAmount(resource):
		selectedAmount = playerScene.inventory.getResourceAmount(resource)
	
	updatePurchaseAmount()


func decreaseAmount(amount: int):
	selectedAmount -= amount
	if selectedAmount < 0:
		selectedAmount = 0
	
	updatePurchaseAmount()


func _on_button_1_pressed():
	increaseAmount(1)


func _on_button_5_pressed():
	increaseAmount(5)


func _on_button_all_pressed():
	increaseAmount(20 if merchantMode == Enums.merchantMode.BUY else playerScene.inventory.getResourceAmount(resource))
