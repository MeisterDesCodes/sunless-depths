extends Control


@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var savebutton = get_node("PanelContainer/MarginContainer/VBoxContainer/SaveGame")


func _ready():
	if playerScene.isInCave:
		savebutton.disable()


func _on_continue_pressed():
	UILoaderS.closeAllUIScenes()


func _on_save_game_pressed():
	PersistenceS.saveGame()
	UILoaderS.closeAllUIScenes()


func _on_load_game_pressed():
	game.resetGame()


func _on_exit_pressed():
	get_tree().quit()
