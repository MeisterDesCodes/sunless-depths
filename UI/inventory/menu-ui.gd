extends Control


@onready var body: PanelContainer = get_node("VBoxContainer/Body")

var inventoryUI: PackedScene = preload("res://UI/inventory/inventory-ui.tscn")
var mapUI: PackedScene = preload("res://UI/inventory/map-ui.tscn")


func _ready():
	loadUIComponent(inventoryUI)


func _on_inventory_pressed():
	loadUIComponent(inventoryUI)


func _on_map_pressed():
	loadUIComponent(mapUI)


func loadUIComponent(scene: PackedScene):
	for child in body.get_children():
		child.get_parent().remove_child(child)
	body.add_child(scene.instantiate())


func _on_button_pressed():
	UILoaderS.closeUIScene(self)
