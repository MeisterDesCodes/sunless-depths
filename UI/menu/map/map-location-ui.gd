extends Control


@export var type: Enums.locationType
@export var attributes: Array[Enums.locationAttribute]

@onready var game: Node2D = get_tree().get_root().get_node("Game")
@onready var typeContainer: TextureRect = get_node("VBoxContainer/PanelContainer/TextureRect")
@onready var attributeContainer: HBoxContainer = get_node("VBoxContainer/HBoxContainer")


func _ready():
	setType()
	setAttributes()


func setType():
	var texture: Texture
	match type:
		Enums.locationType.SETTLEMENT:
			texture = preload("res://assets/UI/icons/locations/Settlement.png")
		Enums.locationType.RUINS:
			texture = preload("res://assets/UI/icons/locations/Ruins.png")
		Enums.locationType.MYSTERY:
			texture = preload("res://assets/UI/icons/locations/Mystery.png")
		Enums.locationType.RETREAT:
			texture = preload("res://assets/UI/icons/locations/Retreat.png")
	typeContainer.texture = texture


func setAttributes():
	for attribute in attributes:
		var attributeScene = preload("res://UI/menu/map/map-location-ui.tscn").instantiate()
		attributeContainer.add_child(attributeScene)
		var texture: Texture
		match attribute:
			Enums.locationAttribute.DARKNESS:
				texture = preload("res://assets/UI/icons/locations/Darkness.png")
			Enums.locationAttribute.EXPOSURE:
				texture = preload("res://assets/UI/icons/locations/Exposure.png")
			Enums.locationAttribute.INFESTATION:
				texture = preload("res://assets/UI/icons/locations/Infestation.png")
			Enums.locationAttribute.DANGER:
				texture = preload("res://assets/UI/icons/locations/Danger.png")
		attributeScene.setup(texture)


func _on_button_mouse_entered():
	AnimationsS.setSize(self, 1.3, 0.15)


func _on_button_mouse_exited():
	AnimationsS.setSize(self, 1, 0.15)


func _on_button_pressed():
	findPathway()
	game.caveGenerator.iterations = 2
	game.generateCave()


func findPathway():
	print(self.get_parent().get_children())





