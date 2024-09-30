@tool
extends Button


@export var texture: Texture2D:
	set(value):
		texture = value
		$"TextureRect".texture = texture
@export var version: int = -1:
	set(value):
		version = value
		_ready()

@export var affectedElement: Control

var selected: bool = false
var initialScale: Vector2
var scaleIncrease: Vector2


func _ready():
	if version == -1:
		theme = null
		flat = true
		$"TextureRect".custom_minimum_size = Vector2(50, 50)
	if version == 0:
		theme = preload("res://assets/UI/themes/UI-elements/button-small.tres")
		flat = false
		$"TextureRect".custom_minimum_size = Vector2(15, 15)
	if version == 1:
		theme = preload("res://assets/UI/themes/UI-elements/button-large.tres")
		flat = false
		$"TextureRect".custom_minimum_size = Vector2(30, 30)
	if version == 2:
		theme = preload("res://assets/UI/themes/UI-elements/button-menu.tres")
		flat = false
		$"TextureRect".custom_minimum_size = Vector2(50, 20)
	
	pivot_offset = Vector2(size.x / 2, size.y / 2)


func setSize():
	initialScale = affectedElement.scale
	scaleIncrease = Vector2(initialScale.x * 1.05, initialScale.x * 1.05)


func _on_mouse_entered():
	if disabled:
		return
	
	changeColor(UtilsS.colorPrimaryBright)
	setSize()
	AnimationsS.setSize(affectedElement, scaleIncrease.x, 0.15)


func _on_mouse_exited():
	if disabled:
		return
	
	if !selected:
		changeColor(UtilsS.colorWhite)
	AnimationsS.setSize(affectedElement, initialScale.x, 0.15)


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
		AnimationsS.changeColor(affectedElement, color, 0.15)



