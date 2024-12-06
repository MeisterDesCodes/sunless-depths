@tool
extends Button


@export var texture: Texture2D:
	set(value):
		texture = value
		$"MarginContainer/TextureRect".texture = texture
@export var version: int = -1:
	set(value):
		version = value
		_ready()

@export var affectedElement: Control = self

@onready var textureRect: TextureRect = get_node("MarginContainer/TextureRect")
@onready var particles: Node2D = get_node("ClickParticles")

var playerScene
var selected: bool = false
var initialScale: Vector2
var scaleIncrease: Vector2
var animationSpeed: float = 0.15
var sizeIncrease: float = 1.035


func _ready():
	if version == -1:
		theme = null
		flat = true
	if version == 0:
		theme = preload("res://assets/UI/themes/UI-elements/button-small.tres")
		flat = false
	if version == 1:
		theme = preload("res://assets/UI/themes/UI-elements/button-large.tres")
		flat = false
	if version == 3:
		theme = preload("res://assets/UI/themes/UI-elements/button-slot.tres")
		flat = false
	
	pivot_offset = Vector2(size.x / 2, size.y / 2)
	particles.position = Vector2(size.x / 2, size.y / 2)
	
	if get_tree():
		playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")


func setSize():
	initialScale = affectedElement.scale
	scaleIncrease = Vector2(initialScale.x * sizeIncrease, initialScale.x * sizeIncrease)


func _on_mouse_entered():
	if disabled:
		return
	
	changeColor(UtilsS.colorPrimaryBright)
	setSize()
	AnimationsS.setSize(affectedElement, scaleIncrease.x, animationSpeed)
	playerScene.soundComponent.onHover()


func _on_mouse_exited():
	if disabled:
		return
	
	if !selected:
		changeColor(UtilsS.colorWhite)
	AnimationsS.setSize(affectedElement, initialScale.x, animationSpeed)


func select():
	if disabled:
		return
	
	changeColor(UtilsS.colorPrimaryBright)
	selected = true


func deselect():
	if disabled:
		return
	
	changeColor(UtilsS.colorWhite)
	selected = false


func changeColor(color: Color):
	if selected:
		AnimationsS.changeColor(affectedElement, color, 0)
	else:
		AnimationsS.changeColor(affectedElement, color, animationSpeed)


func _on_pressed():
	playerScene.soundComponent.onClick()
	UtilsS.playUIParticleEffect(particles, UtilsS.colorPrimary)


func disable(color: Color = UtilsS.colorWhite):
	disabled = true
	changeColor(color)
	textureRect.self_modulate = UtilsS.colorDisabled


func enable(color: Color = UtilsS.colorWhite):
	disabled = false
	changeColor(color)
	textureRect.self_modulate = UtilsS.colorWhite







