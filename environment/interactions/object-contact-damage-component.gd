extends Node2D


@export var damage: float
@export var statusEffects: Array[StatusEffect]

@onready var collisionShape: CollisionShape2D = get_node("Area2D/CollisionShape2D")
@onready var damageRadius = get_node("Area2D")

var entity = preload("res://entities/object.tscn").instantiate()


func _ready():
	collisionShape.shape.size.x = get_parent().get_child(0).get_child(0).shape.size.x
	collisionShape.shape.size.y = get_parent().get_child(0).get_child(0).shape.size.y


func _process(delta):
	var areas = damageRadius.get_overlapping_areas()
	for area in areas:
		var targetEntityScene = area.get_parent()
		var attack = Attack.new(global_position, entity, damage, 0, Enums.weaponTypes.MELEE, statusEffects)
		targetEntityScene.processIncomingAttack(attack)
