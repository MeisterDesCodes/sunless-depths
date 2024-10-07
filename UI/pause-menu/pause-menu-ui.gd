extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var savebutton = get_node("PanelContainer/MarginContainer/VBoxContainer/SaveGame")


func _ready():
	if playerScene.isInCave:
		savebutton.disable()


func _on_continue_pressed():
	UILoaderS.closeAllUIScenes()


func _on_save_game_pressed():
	PersistenceS.saveGame()


func _on_load_game_pressed():
	PersistenceS.loadGame()


func _on_exit_pressed():
	get_tree().quit()
