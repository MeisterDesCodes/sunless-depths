extends PanelContainer


signal choiceSelected

@onready var dialogMenu = get_tree().get_root().get_node("GameController/Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var title = get_node("MarginContainer/LocationDialogContainer/Title")
@onready var description = get_node("MarginContainer/LocationDialogContainer/Description")
@onready var dialogResources = get_node("MarginContainer/LocationDialogContainer/DialogResources")
@onready var choiceContainer = get_node("MarginContainer/LocationDialogContainer/ChoiceContainer")

var completed = false
var dialog: Dialog


func setup(_dialog: Dialog):
	dialog = _dialog
	title.text = dialog.title
	description.text = dialog.description
	for choice in dialog.choices:
		if !(choice in playerScene.completedDialogChoices):
			var choiceScene = preload("res://UI/dialog/dialog-choice-ui.tscn").instantiate()
			choiceContainer.add_child(choiceScene)
			choiceScene.setup(choice)
			choiceScene.choiceSelected.connect(selectChoice)


func selectChoice(choice: DialogChoice):
	choiceSelected.emit(choice)
