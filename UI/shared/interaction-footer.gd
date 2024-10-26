extends Control


@onready var interactionLabel = get_node("PanelContainer/InteractionLabel")


func setup(text: String):
	interactionLabel.text = text
