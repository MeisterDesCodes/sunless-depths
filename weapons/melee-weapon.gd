extends Weapon

class_name MeleeWeapon

signal meleeAttack

@export var damage: float
@export var knockback: float
@export var statusEffects: Array[StatusEffect]
