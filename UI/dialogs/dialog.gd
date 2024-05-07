extends PanelContainer


@onready var dialogMenu = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var title = get_node("LocationDialogContainer/TitleContainer/Title")
@onready var description = get_node("LocationDialogContainer/DescriptionContainer/Description")
@onready var choices = get_node("LocationDialogContainer/ChoiceFrame")
@onready var dialogResources = get_node("LocationDialogContainer/DialogResources")

var completed = false
var dialog: Dialog


func setup(_dialog: Dialog):
	dialog = _dialog
	title.text = dialog.title
	description.text = dialog.description
	for choice in dialog.choices:
		var choiceScene = preload("res://UI/dialogs/dialog-choice-ui.tscn").instantiate()
		choices.add_child(choiceScene)
		choiceScene.setup(choice)
