extends Resource

class_name InventoryResource

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var rarity: Enums.resourceRarity = Enums.resourceRarity.COMMON

var pickupAmount: int = 1
var type: Enums.resourceType = Enums.resourceType.RESOURCE
