extends PanelContainer

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var dialogMenu = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var title = get_node("MarginContainer/LocationChoiceContainer/Title")
@onready var description = get_node("MarginContainer/LocationChoiceContainer/Description")
@onready var requirementContainer = get_node("MarginContainer/LocationChoiceContainer/ChoiceRequirements")
@onready var button = get_node("Button")

var choice: DialogChoice


func setup(_choice: DialogChoice):
	choice = _choice
	title.text = choice.title
	description.text = choice.description
	if !playerScene.inventory.hasResources(choice.requiredResources):
		disableButton()
	for requirement in choice.requiredResources:
		var requirementScene = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		requirementContainer.add_child(requirementScene)
		requirementScene.setup(requirement.resource, requirement.amount, requirement.resource.texture, true, true)


func determineNextDialog(choice: DialogChoice):
	var onClickDialog
	if choice.optionalMoveBackwards >= 0:
		onClickDialog = dialogMenu.dialogTree[dialogMenu.dialogTree.size() - 1 - choice.optionalMoveBackwards]
	else:
		onClickDialog = choice.nextDialog
	return onClickDialog


func onCompletion():
	disableButton()


func disableButton():
	button.disabled = true
	self_modulate = UtilsS.colorDisabled


func _on_button_pressed():
	dialogMenu.clickChoice(choice, determineNextDialog(choice))


func _on_button_mouse_entered():
	if button.disabled:
		return
	
	AnimationsS.changeColor(self, UtilsS.colorPrimaryBright, 0.15)
	AnimationsS.setSize(self, 1.025, 0.15)


func _on_button_mouse_exited():
	if button.disabled:
		return
	
	AnimationsS.changeColor(self, UtilsS.colorWhite, 0.15)
	AnimationsS.setSize(self, 1, 0.15)
