extends Node2D


@export var title: String
@export var initialDialog: Dialog

@onready var dialogMenuUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/DialogMenuUI")
@onready var curiosity = get_node("Curiosity")


func _ready():
	curiosity.onEnter.connect(onEnter)


func onEnter():
	dialogMenuUI.setup(self)
