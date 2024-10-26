extends Control


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var body: PanelContainer = get_node("VBoxContainer/Body")
@onready var buttonContainer: HBoxContainer = get_node("VBoxContainer/PanelContainer2/MarginContainer/HBoxContainer")

var inventoryUI: PackedScene = preload("res://UI/menu/inventory/inventory-ui.tscn")
var mapUI: PackedScene = preload("res://UI/menu/map/map-ui.tscn")


func _on_inventory_pressed():
	loadUIComponent(inventoryUI)
	buttonContainer.get_child(0).select()
	buttonContainer.get_child(1).deselect()


func _on_map_pressed():
	loadUIComponent(mapUI)
	buttonContainer.get_child(1).select()
	buttonContainer.get_child(0).deselect()


func loadUIComponent(scene: PackedScene):
	for child in body.get_children():
		child.get_parent().remove_child(child)
	body.add_child(scene.instantiate())
