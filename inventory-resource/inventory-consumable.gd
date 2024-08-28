extends InventoryResource

class_name InventoryConsumable

@export var cooldown: float
@export var statusEffects: Array[StatusEffect]

var remainingCooldown: float
var isOnCooldown: bool
