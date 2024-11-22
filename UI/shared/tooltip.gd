extends Control


@onready var description: Label = get_node("PanelContainer/MarginContainer/Label")


func _ready():
	visible = false


func setup(_text: String):
	description.text = _text
