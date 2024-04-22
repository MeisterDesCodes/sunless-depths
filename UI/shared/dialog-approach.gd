extends Control


@onready var dialogLabel = get_node("DialogApproachLabel")


func setup(text: String):
	dialogLabel.text = text
