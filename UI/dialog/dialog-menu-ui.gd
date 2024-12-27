extends Control


@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var dialogFunctionComponent = get_tree().get_root().get_node("GameController/Game/DialogFunctionComponent")
@onready var MerchantWindow = get_tree().get_root().get_node("GameController/Game/CanvasLayer/UIControl/Merchant")
@onready var approachLabel = get_tree().get_root().get_node("GameController/Game/CanvasLayer/UIControl/DialogApproachLabel")

@onready var locationTitle = get_node("VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/Title")
@onready var textureRect = get_node("VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer2/MarginContainer/TextureRect")
@onready var scrollContainer = get_node("VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer")
@onready var locationDialogs = get_node("VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LocationDialogs")
@onready var exitButton = get_node("VBoxContainer/MarginContainer/Button")

var currentDialog: PanelContainer = null
var dialogTree: Array[Dialog] = []


func setup(location):
	UtilsS.runShader(textureRect, "dissolve_threshold")
	locationTitle.text = location.title
	
	for child in locationDialogs.get_children():
		child.queue_free()
	
	pushDialog(location.initialDialog, [], false)


func determineNextDialog(choice: DialogChoice, success):
	if success:
		if choice.moveBackwardsS >= 0:
			return {"ND": dialogTree[dialogTree.size() - 1 - choice.moveBackwardsS], "RA": true}
		return {"ND": choice.nextDialogS, "RA": false}
	else:
		if choice.moveBackwardsF >= 0:
			return {"ND": dialogTree[dialogTree.size() - 1 - choice.moveBackwardsF], "RA": true}
		return {"ND": choice.nextDialogF, "RA": false}


func selectChoice(choice: DialogChoice):
	var success = randf() < UtilsS.getStatCheckChance(playerScene, choice.statCheck)
	var nextDialog = determineNextDialog(choice, success)
	var combinedResources: Array[ChoiceResource] = []
	var addedResources = choice.addedResourcesS if success else choice.addedResourcesF
	var removedResources = choice.removedResourcesS if success else choice.removedResourcesF
	for resource in addedResources:
		resource.type = Enums.dialogResourceType.ADD
	for resource in removedResources:
		resource.type = Enums.dialogResourceType.REMOVE
	combinedResources.append_array(addedResources)
	combinedResources.append_array(removedResources)
	
	if choice.oneTimeUse:
		playerScene.completedDialogChoices.append(choice)
		currentDialog.dialog.choices.remove_at(currentDialog.dialog.choices.find(choice))
	
	if choice.function != "":
		executeFunction(choice.function)
	
	pushDialog(nextDialog.ND, combinedResources, nextDialog.RA)
	
	await UtilsS.createTimer(0.15)
	var lastDialog = locationDialogs.get_child(locationDialogs.get_children().size() - 1)
	AnimationsS.scroll(scrollContainer, locationDialogs.size.y - lastDialog.size.y, 0.75)


func pushDialog(dialog: Dialog, choiceResources: Array[ChoiceResource], wasReturned: bool):
	if !dialog:
		UILoaderS.closeUIScene(self)
	else:
		if currentDialog:
			currentDialog.completed = true
			for choice in currentDialog.choiceContainer.get_children():
				choice.onCompletion()
		
		if wasReturned:
			dialogTree.remove_at(dialogTree.size() - 1)
		else:
			dialogTree.append(dialog)
		
		var dialogWindow = preload("res://UI/dialog/dialog-ui.tscn").instantiate()
		locationDialogs.add_child(dialogWindow)
		generateResources(dialogWindow, choiceResources)
		dialogWindow.setup(dialog)
		dialogWindow.choiceSelected.connect(selectChoice)
		currentDialog = dialogWindow
		updateExitButton(dialog)
		playerScene.canExitUIScene = dialog.canExit


func updateExitButton(dialog: Dialog):
	exitButton.disabled = !dialog.canExit


func generateResources(dialog: PanelContainer, choiceResources: Array[ChoiceResource]):
	for resource in choiceResources:
		if resource.type == Enums.dialogResourceType.ADD:
			playerScene.inventory.addResource(resource.resource, resource.amount)
		else:
			playerScene.inventory.removeResource(resource.resource, resource.amount)
		
		var dialogResource = preload("res://UI/dialog/dialog-resource-ui.tscn").instantiate()
		dialog.dialogResources.add_child(dialogResource)
		dialogResource.setup(resource)


func executeFunction(identifier: String):
	var callable = Callable(dialogFunctionComponent, identifier)
	callable.call()



