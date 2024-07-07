extends PanelContainer


signal purchasedResourcesUpdate

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var texture: TextureRect = get_node("NinePatchRect/HBoxContainer/HBoxContainer/Texture")
@onready var description: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer/Name")
@onready var cost: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer2/Cost")
@onready var purchaseAmount: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer3/PurchaseAmount")
@onready var inventoryContainer: HBoxContainer = get_node("NinePatchRect/HBoxContainer/HBoxContainer4")
@onready var inventoryAmount: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer4/InventoryAmount")

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
	purchaseAmount.text = "00"
	inventoryAmount.text = str(playerScene.inventory.getResourceAmount(resource))
	if merchantMode == Enums.merchantMode.BUY:
		inventoryContainer.visible = false


func calculateResourceCost():
	match resource.rarity:
		Enums.resourceRarity.UNCOMMON:
			priceModifier = 1.5
		Enums.resourceRarity.RARE:
			priceModifier = 2.25
		Enums.resourceRarity.EPIC:
			priceModifier = 3.5
		Enums.resourceRarity.LEGENDARY:
			priceModifier = 5.5
	
	var baseCost = 10 if resource.type == Enums.resourceType.MATERIAL else 150
	var sellModifier = 1 if merchantMode == Enums.merchantMode.BUY else 0.35
	return round(baseCost * priceModifier * sellModifier)


func reset():
	selectedAmount = 0
	inventoryAmount.text = str(playerScene.inventory.getResourceAmount(resource))
	updateAmount()


func updateAmount():
	purchaseAmount.text = str(selectedAmount)
	if selectedAmount < 10:
		purchaseAmount.text = "0" + purchaseAmount.text
	purchasedResourcesUpdate.emit()


func calculateTotalCost():
	return selectedAmount * int(cost.text)


func _on_less_button_pressed():
	if selectedAmount > 0:
		selectedAmount -= 1
		updateAmount()


func _on_more_button_pressed():
	if selectedAmount > 0&& resource.type == Enums.resourceType.WEAPON:
		return
	
	if selectedAmount < 99 && (merchantMode == Enums.merchantMode.BUY || selectedAmount < playerScene.inventory.getResourceAmount(resource)):
		selectedAmount += 1
		updateAmount()
