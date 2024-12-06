extends Resource

class_name InventoryResource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
@export var rarity: Enums.resourceRarity = Enums.resourceRarity.COMMON
@export var weight: float = 1

var pickupAmount: int = 1
var type: Enums.resourceType = Enums.resourceType.RESOURCE
var filterType: Enums.resourceType = Enums.resourceType.RESOURCE
var hidden: bool = false
