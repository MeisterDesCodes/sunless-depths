extends Node2D


@export var lifetime: int
@export var spawners: Node2D

@onready var interaction = get_node("Interaction")

var effect: StatusEffect = preload("res://entities/resources/status-effects/awareness.tres")

func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	for spawner in spawners.get_children():
		spawner.setup(spawners.get_parent().get_parent().get_parent(), 500, 500)
	
	for i in 5:
		await get_tree().create_timer(0.5).timeout
		for spawner in spawners.get_children():
			var enemy = spawner.spawnEntity()
			UtilsS.applyStatusEffect(enemy, enemy, effect)
