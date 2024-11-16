extends Node2D


@export var entityScene: CharacterBody2D

@onready var damageRadius = get_node("Area2D")


func _process(delta):
	if !entityScene.canDealContactDamage:
		return
	
	var areas = damageRadius.get_overlapping_areas()
	for area in areas:
		var targetEntityScene = area.get_parent()
		var damage: float = entityScene.currentAttack.damage
		var knockback: float = entityScene.currentAttack.knockback
		var attack = Attack.new(global_position, entityScene, damage, knockback, Enums.weaponTypes.MELEE, entityScene.currentAttack.statusEffects, false)
		targetEntityScene.processIncomingAttack(attack)
