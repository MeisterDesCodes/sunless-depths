extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var gold = preload("res://inventory-resource/resources/primary/gold.tres")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")
@onready var merchantTitle = get_node("NinePatchRect/LocationContainer/PanelContainer3/HBoxContainer/HBoxContainer2/TotalGold")

@onready var resourcesWindow = get_node("NinePatchRect/LocationContainer/ScrollContainer/Resources")
@onready var totalCostsLabel = get_node("NinePatchRect/LocationContainer/PanelContainer2/HBoxContainer/HBoxContainer2/TotalCost")
@onready var purchaseButton = get_node("NinePatchRect/LocationContainer/PanelContainer2/HBoxContainer/Purchase")
@onready var totalGold = get_node("NinePatchRect/LocationContainer/PanelContainer3/HBoxContainer/HBoxContainer2/TotalGold")

var merchant = null
var merchantMode = Enums.merchantMode.BUY


func setup(merchantCuriosity):
	merchant = merchantCuriosity
	merchantTitle.text = merchant.title
	generateBuyResources()


func generateBuyResources():
	generateResources(merchant.merchantResources, Enums.merchantMode.BUY)


func generateSellResources():
	var resources: Array[InventoryResource] = []
	for slot in playerScene.inventory.resourceSlots:
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
	if totalCosts > playerScene.inventory.getResourceAmount(gold) && merchantMode == Enums.merchantMode.BUY:
		purchaseButton.disabled = true
	else:
		purchaseButton.disabled = false
		
	totalGold.text = str(playerScene.inventory.getResourceAmount(gold))


func purchase():
	playerScene.inventory.removeResource(gold, int(totalCostsLabel.text))
	for merchantResource in resourcesWindow.get_children():
		if merchantResource.selectedAmount > 0:
			playerScene.inventory.addResource(merchantResource.resource, merchantResource.selectedAmount)
			merchantResource.reset()


func sell():
	playerScene.inventory.addResource(gold, int(totalCostsLabel.text))
	for merchantResource in resourcesWindow.get_children():
		if merchantResource.selectedAmount > 0:
			playerScene.inventory.removeResource(merchantResource.resource, merchantResource.selectedAmount)
			merchantResource.reset()


func _on_purchase_pressed():
	if merchantMode == Enums.merchantMode.BUY:
		purchase()
	else:
		sell()
		generateSellResources()


func _on_leave_pressed():
	queue_free()
	playerScene.isInDialog = false


func _on_buy_pressed():
	merchantMode = Enums.merchantMode.BUY
	purchaseButton.text = "Purchase"
	generateBuyResources()


func _on_sell_pressed():
	merchantMode = Enums.merchantMode.SELL
	purchaseButton.text = "Sell"
	generateSellResources()
