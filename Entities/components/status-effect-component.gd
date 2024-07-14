extends Node2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@export var entityScene: CharacterBody2D

@onready var statusEffectTimer = get_node("StatusEffectApply")

var statusEffects: Array[StatusEffect]


func _on_status_effect_apply_timeout():
	if playerScene.isInDialog:
		return
	
	for effect in statusEffects:
		effect.onTick(entityScene)
