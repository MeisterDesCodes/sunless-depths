extends PanelContainer


@onready var player = get_tree().get_root().get_node("Game/Entities/Player")


func setup(choiceResource: ChoiceResource):
	var description = "gained" if choiceResource.type == Enums.dialogResourceType.ADD else "lost"
	$"HBoxContainer/Label".text = "You've " + description + " " + str(choiceResource.amount) + "x " + choiceResource.resource.name + "! (new total: " + str(player.inventory.getResourceAmount(choiceResource.resource)) + ")"
	$"HBoxContainer/DialogChoiceRequirement".setup(choiceResource, false)
