extends InventoryWeapon

class_name RangedWeapon

signal rangedAttack

@export var damageModifier: float
@export var speedModifier: float
@export var knockbackModifier: float
@export var spread: float
@export var projectileAmount: int = 1
@export var statusEffects: Array[StatusEffect]
@export var ammunition: InventoryAmmunition
