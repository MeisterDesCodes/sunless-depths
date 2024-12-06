extends Control


signal cardSelected

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var cardsContainer: HBoxContainer = get_node("MarginContainer/HBoxContainer/Cards")

var allCardsTier1 = preload("res://UI/menu/inventory/level-up-cards/resources/tier-1/cards-tier-1.tres").allCards
var allCardsTier2 = preload("res://UI/menu/inventory/level-up-cards/resources/tier-2/cards-tier-2.tres").allCards
var allCardsTier3 = preload("res://UI/menu/inventory/level-up-cards/resources/tier-3/cards-tier-3.tres").allCards
var allCards: Array[LevelUpCard]

var amount: int = 4
var pickedCards: Array[LevelUpCard]


func _ready():
	allCards = allCardsTier1
	allCards.append_array(allCardsTier2)
	allCards.append_array(allCardsTier3)
	for i in amount:
		var card = getRandomCard()
		if card:
			pickedCards.append(card)
			var cardInstance = preload("res://UI/menu/inventory/level-up-cards/level-up-card-ui.tscn").instantiate()
			cardsContainer.add_child(cardInstance)
			cardInstance.setup(card)
			cardInstance.cardSelected.connect(closeScreen)
			
			if card in allCardsTier2:
				cardInstance.self_modulate = UtilsS.colorLegendary
			
			if card in allCardsTier3:
				cardInstance.self_modulate = UtilsS.colorPrimary


func getRandomCard():
	var filteredCards = allCards.filter(func(card): return isValidCard(card) && !(card in pickedCards) && !(card in playerScene.equippedCards))
	return filteredCards.pick_random()


func isValidCard(card: LevelUpCard):
	for requirement in card.requirements:
		if !(requirement in playerScene.equippedCards):
			return false
	return true


func closeScreen():
	cardSelected.emit()
	UILoaderS.closeUIScene(UILoaderS.currentUIScenes[UILoaderS.currentUIScenes.size() - 1])
	playerScene.canExitUIScene = true


