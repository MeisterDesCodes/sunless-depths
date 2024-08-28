extends Node2D


@export var damage: float
@export var statusEffects: Array[StatusEffect]

@onready var collisionShape: CollisionShape2D = get_node("Area2D/CollisionShape2D")
@onready var damageRadius = get_node("Area2D")

var entity = preload("res://entities/environmental-object.tscn").instantiate()


func _ready():
	collisionShape.shape.extents.x = get_parent().get_child(0).get_child(0).shape.extents.x
	collisionShape.shape.extents.y = get_parent().get_child(0).get_child(0).shape.extents.y


func _process(delta):
	var areas = damageRadius.get_overlapping_areas()
	for area in areas:
		var targetEntityScene = area.get_parent()
		var attack = Attack.new(global_position, entity, damage, 0, Enums.weaponTypes.MELEE, statusEffects, false)
		targetEntityScene.processIncomingAttack(attack)
