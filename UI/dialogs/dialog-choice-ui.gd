extends PanelContainer

@onready var player = get_tree().get_root().get_node("Game/Entities/Player")
@onready var dialogMenu = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var title = get_node("LocationChoiceContainer/PanelContainer/Title")
@onready var description = get_node("LocationChoiceContainer/PanelContainer2/Description")
@onready var requirements = get_node("LocationChoiceContainer/ChoiceRequirements")
@onready var button = get_node("Button")

func setup(choice: DialogChoice):
	title.text = choice.title
	description.text = choice.description
	button.connect("pressed", dialogMenu.clickChoice.bind(choice, determineNextDialog(choice)))
	if !player.inventory.hasResources(choice.requiredResources):
		button.disabled = true
	for requirement in choice.requiredResources:
		var requirementScene = preload("res://UI/dialogs/dialog-choice-requirement-ui.tscn").instantiate()
		requirements.add_child(requirementScene)
		requirementScene.setup(requirement, true)


func determineNextDialog(choice: DialogChoice):
	var onClickDialog
	if choice.optionalMoveBackwards >= 0:
		onClickDialog = dialogMenu.dialogTree[dialogMenu.dialogTree.size() - 1 - choice.optionalMoveBackwards]
	else:
		onClickDialog = choice.nextDialog
	return onClickDialog


func onCompletion():
	button.disabled = true
