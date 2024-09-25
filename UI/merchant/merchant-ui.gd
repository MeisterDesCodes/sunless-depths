extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var gold = preload("res://inventory-resource/resources/material/primary/gold.tres")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")

@onready var merchantTitle = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/PanelContainer/Title")
@onready var resourcesWindow = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/ScrollContainer/Resources")
@onready var totalCostsLabel = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/PanelContainer2/HBoxContainer/HBoxContainer2/TotalCost")
@onready var purchaseButton = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/PanelContainer2/HBoxContainer/Purchase")
@onready var totalGold = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/PanelContainer3/HBoxContainer/HBoxContainer2/TotalGold")
@onready var buttonContainer = get_node("VBoxContainer/PanelContainer/MarginContainer/LocationContainer/PanelContainer3/HBoxContainer")

var merchant = null
var merchantMode = Enums.merchantMode.BUY


func setup(merchantCuriosity):
	merchant = merchantCuriosity
	merchantTitle.text = merchant.title
	setupAvailableBlueprints()
	_on_buy_pressed()


func setupAvailableBlueprints():
	var blueprints: Array[InventoryResource]
	if merchant.hasAdditionalBlueprints:
		match merchant.tier:
			0:
				blueprints = preload("res://inventory-resource/resources/material/common/0 - materials-common.tres").allResources
			1:
				blueprints = preload("res://inventory-resource/resources/material/uncommon/0 - materials-uncommon.tres").allResources
		
		merchant.availableBlueprints.append_array(blueprints)


func generateBuyResources():
	generateResources(merchant.availableBlueprints, Enums.merchantMode.BUY)


func generateSellResources():
	var resources: Array[InventoryResource] = []
	for slot in playerScene.inventory.resourceSlots.filter(func(slot): return slot.resource.rarity != Enums.resourceRarity.PRIMARY):
		resources.append(slot.resource)
	generateResources(resources, Enums.merchantMode.SELL)


func generateResources(resources: Array[InventoryResource], merchantMode: Enums.merchantMode):
	clearResources()
	updateTotalCosts()
	for resource in resources:
		var merchantResource = preload("res://UI/merchant/merchant-resource-ui.tscn").instantiate()
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
			if merchantResource.resource in playerScene.equippedWeapons:
				playerScene.equippedWeapons[playerScene.equippedWeapons.find(merchantResource.resource)] = null
				playerScene.updateWeapons()


func _on_purchase_pressed():
	if merchantMode == Enums.merchantMode.BUY:
		purchase()
	else:
		sell()
		generateSellResources()


func _on_leave_pressed():
	UILoaderS.closeUIScene(self)


func _on_buy_pressed():
	merchantMode = Enums.merchantMode.BUY
	purchaseButton.text = "Purchase"
	generateBuyResources()
	buttonContainer.get_child(0).select()
	buttonContainer.get_child(1).deselect()


func _on_sell_pressed():
	merchantMode = Enums.merchantMode.SELL
	purchaseButton.text = "Sell"
	generateSellResources()
	buttonContainer.get_child(1).select()
	buttonContainer.get_child(0).deselect()





