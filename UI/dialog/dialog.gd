extends PanelContainer


@onready var dialogMenu = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var title = get_node("MarginContainer/LocationDialogContainer/TitleContainer/Title")
@onready var description = get_node("MarginContainer/LocationDialogContainer/DescriptionContainer/Description")
@onready var dialogResources = get_node("MarginContainer/LocationDialogContainer/DialogResources")
@onready var choiceContainer = get_node("MarginContainer/LocationDialogContainer/ChoiceFrame")

var completed = false
var dialog: Dialog


func setup(_dialog: Dialog):
	dialog = _dialog
	title.text = dialog.title
	description.text = dialog.description
	for choice in dialog.choices:
		var choiceScene = preload("res://UI/dialog/dialog-choice-ui.tscn").instantiate()
		choiceContainer.add_child(choiceScene)
		choiceScene.setup(choice)
