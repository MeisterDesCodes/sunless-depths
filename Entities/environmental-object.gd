extends CharacterBody2D


@export var entityResource: Entity


var attackCounter: int = 0

var meleeDamageModifier: float = 1
var rangedDamageModifier: float = 1
var attackDelayModifier: float = 1
var healthModifier: float = 1
var movementSpeedModifier: float = 1
var sightRadiusModifier: float = 1
var lootModifier: float = 1
var effectStrengthModifier: float = 1
var staminaCostModifier: float = 1
var criticalDamageModifier: float = 1
var knockbackModifier: float = 1
var effectDurationRandomModifier: float = 1

var rangedDamageAfterMeleeAttack: float = 0
var meleeDamageAfterRangedAttack: float = 0
var thirdAttackDamage: float = 0
var sightRadiusEntryEffect: float = 0


func isEnvironmentalObject():
	pass
