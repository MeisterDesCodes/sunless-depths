extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var MerchantWindow = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/Merchant")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")

@onready var locationTitle = get_node("VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/Title")
@onready var scrollContainer = get_node("VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer")
@onready var locationDialogs = get_node("VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LocationDialogs")

var currentDialog: PanelContainer = null
var dialogTree: Array[Dialog] = []


func setup(location):
	locationTitle.text = location.title
	
	for child in locationDialogs.get_children():
		child.queue_free()
	
	pushDialog(location.initialDialog, [], false)


func clickChoice(choice: DialogChoice, nextDialog: Dialog):
	var combinedResources: Array[ChoiceResource] = []
	for resource in choice.addedResources:
		resource.type = Enums.dialogResourceType.ADD
	for resource in choice.removedResources:
		resource.type = Enums.dialogResourceType.REMOVE
	combinedResources.append_array(choice.addedResources)
	combinedResources.append_array(choice.removedResources)
	
	if choice.oneTimeUse:
		currentDialog.dialog.choices.remove_at(currentDialog.dialog.choices.find(choice))
	
	if choice.function != "":
		executeFunction(choice.function)
	
	pushDialog(nextDialog, combinedResources, choice.optionalMoveBackwards > 0)
	
	await get_tree().create_timer(0.15).timeout
	var lastDialog = locationDialogs.get_child(locationDialogs.get_children().size() - 1)
	AnimationsS.scroll(scrollContainer, locationDialogs.size.y - lastDialog.size.y, 0.75)


func pushDialog(dialog: Dialog, choiceResources: Array[ChoiceResource], wasReturned: bool):
	if dialog != null:
		if currentDialog != null:
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
		currentDialog = dialogWindow
	else:
		UILoaderS.closeUIScene(self)


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
	var callable = Callable(DialogFunctionsS, identifier)
	callable.call()



