extends Control

@onready var dialogWindow = $"LocationContainer/MarginDialog/LocationDialogContainer"
@onready var locationTitle = $"LocationContainer/MarginDialog/LocationDialogContainer/TitleContainer/Title"

var isOpen: bool = true
var currentLocation

func _ready():
	toggleDialog()
	
	
func toggleDialog():
	isOpen = !isOpen
	visible = !visible


func setupLocation(location):
	currentLocation = location
	locationTitle.text = location.title
	toggleDialog()
	pushDialog(location.dialog1)


func pushDialog(dialog):
	removeChildren()
	dialogWindow.get_child(0).get_child(0).text = dialog.title
	dialogWindow.get_child(1).get_child(0).text = dialog.description
	for choice in dialog.choices:
		var button = Button.new()
		button.text = choice
		dialogWindow.get_child(2).add_child(button)
		button.connect("pressed", currentLocation.selectChoice.bind(choice.to_lower()))
		
	
	
func leave():
	visible = false
	removeChildren()
	
	
func removeChildren():
	for child in dialogWindow.get_child(2).get_children():
		child.queue_free()
