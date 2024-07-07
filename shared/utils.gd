extends Node


class_name Utils


var colorPrimary = Color("#E14F21")
var colorCommon = Color("#FFFFFF")
var colorUncommon = Color("#54A32F")
var colorRare = Color("#1E5F9B")
var colorEpic = Color("#4F2397")
var colorLegendary = Color("#D3A42B")
var colorMissing = Color("#B51111")
var colorBlack = Color("#000000")
var colorGrey = Color("#404040")
var colorTransparent = Color("#FFFFFF", 0)


func updateResourceType(resource: InventoryResource):
	if resource is InventoryMaterial:
		resource.type = Enums.resourceType.MATERIAL
	if resource is InventoryUsable:
		resource.type = Enums.resourceType.USABLE
	if resource is InventoryBlueprint:
		resource.type = Enums.resourceType.BLUEPRINT
	if resource is InventoryWeapon:
		resource.type = Enums.resourceType.WEAPON
	if resource is InventoryEquipment:
		resource.type = Enums.resourceType.EQUIPMENT
	if resource is InventoryAmmunition:
		resource.type = Enums.resourceType.AMMUNITION


func getScalingValue(value: float):
	return 100 / (value + 100)


func getRandomRange(value: float):
	return randf_range(0.75 * value, 1.25 * value)


func getEnumValue(_enum, _key):
	var value = _enum.keys()[_key].to_lower()
	value = value[0].to_upper() + value.substr(1,-1)
	return value


func getRarityColor(rarity: Enums.resourceRarity):
	match rarity:
		Enums.resourceRarity.PRIMARY:
			return UtilsS.colorPrimary
		Enums.resourceRarity.COMMON:
			return UtilsS.colorCommon
		Enums.resourceRarity.UNCOMMON:
			return UtilsS.colorUncommon
		Enums.resourceRarity.RARE:
			return UtilsS.colorRare
		Enums.resourceRarity.EPIC:
			return UtilsS.colorEpic
		Enums.resourceRarity.LEGENDARY:
			return UtilsS.colorLegendary


func calculateMeleeScaling(attacker: Entity):
	return attacker.ferocity


func calculateRangedScaling(attacker: Entity):
	return attacker.ferocity * 0.5 + attacker.perception * 0.5




