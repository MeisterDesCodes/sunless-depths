extends PanelContainer

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var dialogMenu = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
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
	if !playerScene.inventory.hasResources(choice.requiredResources):
		disableButton()
	
	for requirement in choice.requiredResources:
		var requirementScene = preload("res://UI/shared/resource-icon-ui.tscn").instantiate()
		requirementContainer.add_child(requirementScene)
		requirementScene.setup(requirement.resource, requirement.amount, requirement.resource.texture, true, true)
	
	if choice.statCheck:
		dialogStatCheck.setup(choice)
	else:
		dialogStatCheck.visible = false


func onCompletion():
	disableButton()


func disableButton():
	button.disable(UtilsS.colorDisabled)


func _on_button_pressed():
	dialogMenu.clickChoice(choice)
