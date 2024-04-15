extends Node


class_name Utils


var colorPrimary = Color("#E14F21")
var colorCommon = Color("#FFFFFF")
var colorUncommon = Color("#54A32F")
var colorRare = Color("#1E5F9B")
var colorEpic = Color("#4F2397")
var colorLegendary = Color("#D3A42B")
var colorMissing = Color("#B51111")


func updateResource(resource: InventoryResource):
	if resource is InventoryMaterial:
		resource.type = Enums.resourceType.MATERIAL
	if resource is InventoryBlueprint:
		resource.type = Enums.resourceType.BLUEPRINT
	if resource is Weapon:
		resource.type = Enums.resourceType.WEAPON
	if resource is InventoryUsable:
		resource.type = Enums.resourceType.USABLE


func getScalingValue(value: float):
	return 100 / (value + 100)


func generateRandomRange(value: float):
	return randf_range(0.75 * value, 1.25 * value)

