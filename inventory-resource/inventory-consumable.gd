extends InventoryResource

class_name InventoryConsumable

@export var cooldown: float
@export var remainingCooldown: float
@export var statusEffects: Array[StatusEffect]

var isOnCooldown: bool
