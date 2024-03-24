extends Control


@onready var player = get_tree().get_root().get_node("Game/Entities/Player")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")
@onready var gold = preload("res://inventory-resource/resources/gold.tres")

@onready var resourcesWindow = get_node("NinePatchRect/LocationContainer/ScrollContainer/Resources")
@onready var totalCostsLabel = get_node("NinePatchRect/LocationContainer/PanelContainer2/HBoxContainer/HBoxContainer2/TotalCost")
@onready var purchaseButton = get_node("NinePatchRect/LocationContainer/PanelContainer2/HBoxContainer/Purchase")
@onready var merchantTitle = get_node("NinePatchRect/LocationContainer/PanelContainer/Title")

var merchant = null
var merchantMode = Enums.merchantMode.BUY


func _ready():
	toggleMerchant()


func setup(merchantCuriosity):
	toggleMerchant()
	merchant = merchantCuriosity
	merchantTitle.text = merchant.title
	generateBuyResources()


func generateBuyResources():
	generateResources(merchant.merchantResources, Enums.merchantMode.BUY)


func generateSellResources():
	var resources: Array[InventoryResource] = []
	for slot in player.inventory.assetSlots:
		resources.append(slot.resource)
	generateResources(resources, Enums.merchantMode.SELL)


func generateResources(resources: Array[InventoryResource], merchantMode: Enums.merchantMode):
	clearResources()
	updateTotalCosts()
	for resource in resources:
		var merchantResource = preload("res://UI/merchants/merchant-resource-ui.tscn").instantiate()
		resourcesWindow.add_child(merchantResource)
		merchantResource.setup(resource, merchantMode, merchant.priceModifier)
		merchantResource.purchasedResourcesUpdate.connect(updateTotalCosts)


func clearResources():
	for resource in resourcesWindow.get_children():
		resource.get_parent().remove_child(resource)
		resource.queue_free()


func updateTotalCosts():
	var totalCosts = 0

	for merchantResource in resourcesWindow.get_children():
		totalCosts += merchantResource.calculateTotalCost()
	totalCostsLabel.text = str(totalCosts)
	if totalCosts > player.inventory.getResourceAmount(gold) && merchantMode == Enums.merchantMode.BUY:
		purchaseButton.disabled = true
	else:
		purchaseButton.disabled = false


func purchase():
	player.inventory.removeResource(gold, int(totalCostsLabel.text))
	for merchantResource in resourcesWindow.get_children():
		if merchantResource.selectedAmount > 0:
			player.inventory.addResource(merchantResource.resource, merchantResource.selectedAmount)
			merchantResource.reset()


func sell():
	player.inventory.addResource(gold, int(totalCostsLabel.text))
	for merchantResource in resourcesWindow.get_children():
		if merchantResource.selectedAmount > 0:
			player.inventory.removeResource(merchantResource.resource, merchantResource.selectedAmount)
			merchantResource.reset()


func toggleMerchant():
	visible = !visible


func _on_purchase_pressed():
	if merchantMode == Enums.merchantMode.BUY:
		purchase()
	else:
		sell()
		generateSellResources()


func _on_leave_pressed():
	toggleMerchant()
	player.isInDialog = false


func _on_buy_pressed():
	merchantMode = Enums.merchantMode.BUY
	purchaseButton.text = "Purchase"
	generateBuyResources()


func _on_sell_pressed():
	merchantMode = Enums.merchantMode.SELL
	purchaseButton.text = "Sell"
	generateSellResources()
