extends Control


signal cardSelected

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var cardsContainer: HBoxContainer = get_node("Cards")

var allCards = preload("res://UI/menu/inventory/level-up/resources/cards.tres").allCards
var amount: int = 4
var pickedCards: Array[LevelUpCard]


func _ready():
	for i in amount:
		var card = getRandomCard()
		if card:
			pickedCards.append(card)
			var cardInstance = preload("res://UI/menu/inventory/level-up/level-up-card-ui.tscn").instantiate()
			cardsContainer.add_child(cardInstance)
			cardInstance.setup(card)
			cardInstance.cardSelected.connect(closeScreen)


func getRandomCard():
	var filteredCards = allCards.filter(func(card): return isValidCard(card) && !(card in pickedCards) && !(card in playerScene.selectedCards))
	return filteredCards.pick_random()


func isValidCard(card: LevelUpCard):
	for requirement in card.requirements:
		if !(requirement in playerScene.selectedCards):
			return false
	return true


func closeScreen():
	cardSelected.emit()
	UILoaderS.closeUIScene(UILoaderS.currentUIScenes[UILoaderS.currentUIScenes.size() - 1])


