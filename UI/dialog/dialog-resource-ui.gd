extends PanelContainer


@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")


func setup(choiceResource: ChoiceResource):
	var description = "gained" if choiceResource.type == Enums.dialogResourceType.ADD else "lost"
	$"HBoxContainer/Label".text = "You've " + description + " " + str(choiceResource.amount) + "x " + choiceResource.resource.name + "! (new total: " + str(playerScene.inventory.getResourceAmount(choiceResource.resource)) + ")"
	$"HBoxContainer/DialogChoiceRequirement".setup(choiceResource.resource, choiceResource.amount, choiceResource.resource.texture, false, false)
