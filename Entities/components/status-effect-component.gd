extends Node2D


@export var entityScene: CharacterBody2D

@onready var statusEffectTimer = get_node("StatusEffectApply")

var statusEffects: Array[StatusEffect]


func _on_status_effect_apply_timeout():
	for effect in statusEffects:
		effect.apply(entityScene)
