extends Control


@onready var player = get_tree().get_root().get_node("Game/Entities/Player")
@onready var MerchantWindow = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/Merchant")
@onready var approachLabel = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogApproachLabel")

@onready var locationTitle = get_node("NinePatchRect/LocationContainer/PanelContainer/Title")
@onready var locationDialogs = get_node("NinePatchRect/LocationContainer/ScrollContainer/LocationDialogs")

var currentDialog: PanelContainer = null
var dialogTree: Array[Dialog] = []


func _ready():
	toggleDialogMenu()


func toggleDialogMenu():
	visible = !visible


func setup(location):
	toggleDialogMenu()
	locationTitle.text = location.title
	
	for child in locationDialogs.get_children():
		child.queue_free()
	
	pushDialog(location.initialDialog, [])


func clickChoice(choice: DialogChoice, nextDialog: Dialog):
	var combinedResources: Array[ChoiceResource] = []
	for resource in choice.addedResources:
		resource.type = Enums.dialogResourceType.ADD
	for resource in choice.removedResources:
		resource.type = Enums.dialogResourceType.REMOVE
	combinedResources.append_array(choice.addedResources)
	combinedResources.append_array(choice.removedResources)
	pushDialog(nextDialog, combinedResources)


func pushDialog(dialog: Dialog, choiceResources: Array[ChoiceResource]):
	if dialog != null:
		if currentDialog != null:
			currentDialog.completed = true
			for choice in currentDialog.choices.get_children():
				choice.onCompletion()
		dialogTree.append(dialog)
		var dialogWindow = preload("res://UI/dialogs/dialog.tscn").instantiate()
		locationDialogs.add_child(dialogWindow)
		generateResources(dialogWindow, choiceResources)
		dialogWindow.setup(dialog)
		currentDialog = dialogWindow
	else:
		leave()


func generateResources(dialog: PanelContainer, choiceResources: Array[ChoiceResource]):
	for resource in choiceResources:
		if resource.type == Enums.dialogResourceType.ADD:
			player.inventory.addResource(resource.resource, resource.amount)
		else:
			player.inventory.removeResource(resource.resource, resource.amount)
		
		var dialogResource = preload("res://UI/dialogs/dialog-resource.tscn").instantiate()
		dialog.dialogResources.add_child(dialogResource)
		dialogResource.setup(resource)


func leave():
	toggleDialogMenu()
	player.isInDialog = false


func _on_leave_pressed():
	leave()
