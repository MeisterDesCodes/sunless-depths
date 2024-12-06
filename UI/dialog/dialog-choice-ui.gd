extends PanelContainer


signal choiceSelected

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var title = get_node("MarginContainer/LocationChoiceContainer/Title")
@onready var description = get_node("MarginContainer/LocationChoiceContainer/Description")
@onready var requirementContainer = get_node("MarginContainer/LocationChoiceContainer/HBoxContainer/ChoiceRequirements")
@onready var dialogStatCheck = get_node("MarginContainer/LocationChoiceContainer/HBoxContainer/DialogStatCheckUI")
@onready var button = get_node("Control/Button")

var choice: DialogChoice


func setup(_choice: DialogChoice):
	choice = _choice
	title.text = choice.title
	description.text = choice.description
	if !checkChoiceValid():
		disableButton()
	
	for requirement in choice.requiredResources:
		var requirementScene = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		requirementContainer.add_child(requirementScene)
		requirementScene.setup(requirement.resource, requirement.amount, requirement.resource.texture, true, true)
		
	for requirement in choice.forbiddenResources:
		var requirementScene = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		requirementContainer.add_child(requirementScene)
		requirementScene.setup(requirement.resource, requirement.amount, requirement.resource.texture, true, true, true)
	
	if choice.statCheck:
		dialogStatCheck.setup(choice)
	else:
		dialogStatCheck.visible = false


func checkChoiceValid():
	return playerScene.inventory.hasResources(choice.requiredResources) && \
		(choice.forbiddenResources.is_empty() || \
		!playerScene.inventory.hasResources(choice.forbiddenResources))


func onCompletion():
	disableButton()


func disableButton():
	button.disable(UtilsS.colorDisabled)


func _on_button_pressed():
	choiceSelected.emit(choice)
