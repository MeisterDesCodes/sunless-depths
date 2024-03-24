extends PanelContainer


signal purchasedResourcesUpdate

@onready var player = get_tree().get_root().get_node("Game/Entities/Player")
@onready var texture: TextureRect = get_node("NinePatchRect/HBoxContainer/HBoxContainer/Texture")
@onready var description: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer/Name")
@onready var cost: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer2/Cost")
@onready var purchaseAmount: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer3/PurchaseAmount")
@onready var inventoryAmount: Label = get_node("NinePatchRect/HBoxContainer/HBoxContainer4/InventoryAmount")

var resource: InventoryResource
var selectedAmount = 0
var merchantMode = Enums.merchantMode.BUY
var priceModifier: float = 1


func setup(merchantResource: InventoryResource, mode: Enums.merchantMode, price: float):
	resource = merchantResource
	merchantMode = mode
	priceModifier = price
	texture.texture = resource.texture
	description.text = resource.name
	cost.text = str(calculateResourceCost(resource))
	purchaseAmount.text = "00"
	inventoryAmount.text = str(player.inventory.getResourceAmount(resource))


func calculateResourceCost(resource: InventoryResource):
	match resource.rarity:
		Enums.resourceRarity.UNCOMMON:
			1.25
		Enums.resourceRarity.RARE:
			1.75
		Enums.resourceRarity.EPIC:
			2.5
		Enums.resourceRarity.LEGENDARY:
			3.5
	
	var sellModifier = 1 if merchantMode == Enums.merchantMode.BUY else 0.35
	return 100 * priceModifier * sellModifier


func reset():
	selectedAmount = 0
	inventoryAmount.text = str(player.inventory.getResourceAmount(resource))
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
	if selectedAmount < 99 && (merchantMode == Enums.merchantMode.BUY || selectedAmount < player.inventory.getResourceAmount(resource)):
		selectedAmount += 1
		updateAmount()
