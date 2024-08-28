extends Node


class_name Attack


var position: Vector2
var caster: CharacterBody2D
var damage: float
var knockback: float
var type: Enums.weaponTypes
var statusEffects: Array[StatusEffect]
var isCrit: bool


func _init(_position, _caster, _damage, _knockback, _type, _statusEffects, _isCrit):
	position = _position
	caster = _caster
	damage = _damage
	knockback = _knockback
	type = _type
	statusEffects = _statusEffects
	isCrit = _isCrit
