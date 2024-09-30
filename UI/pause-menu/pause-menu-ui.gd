extends Control


func _on_continue_pressed():
	UILoaderS.closeAllUIScenes()


func _on_save_game_pressed():
	PersistenceS.saveGame()


func _on_load_game_pressed():
	PersistenceS.loadGame()


func _on_exit_pressed():
	get_tree().quit()
