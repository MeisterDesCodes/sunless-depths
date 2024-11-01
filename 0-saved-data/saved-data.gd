extends Resource


class_name SavedData

@export_group("Player")

@export_subgroup("Information")
@export var area: Enums.locations
@export var position: Vector2
@export var level: int
@export var health: float
@export var supplies: float
@export var oxygen: float
@export var stamina: float
@export var visitedLocations: Array[Enums.locations]
@export var exploredLocations: Array[Enums.locations]

@export_subgroup("Assets")
@export var inventory: Array[InventorySlot]
@export var storage: Array[InventorySlot]
@export var equippedWeapons: Array[InventoryWeapon]
@export var equippedAmmunitions: Array[InventoryAmmunition]
@export var equippedGear: Array[InventoryEquipment]
@export var equippedConsumable: InventoryConsumable
@export var equippedCards: Array[LevelUpCard]


