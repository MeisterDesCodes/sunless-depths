extends Node2D


signal enemiesDefeated

@export var lifetime: int
@export var spawners: Node2D

@onready var interaction = get_node("Interaction")

var effectAwareness: StatusEffect = preload("res://entities/resources/status-effects/awareness-arena.tres")
var effectSpeed: StatusEffect = preload("res://entities/resources/status-effects/speed-arena.tres")

var enemies: Array[CharacterBody2D]


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	for i in 3:
		await get_tree().create_timer(0.75).timeout
		for spawner in spawners.get_children():
			spawner.setup(spawners.get_parent().get_parent().get_parent(), 500, 500)
			var enemyScene = spawner.spawnEntity()
			UtilsS.applyStatusEffects(enemyScene, enemyScene, [effectAwareness, effectSpeed])
			enemies.append(enemyScene)
			enemyScene.onDeath.connect(reduceAmount)


func reduceAmount(enemy: CharacterBody2D):
	enemies.remove_at(enemies.find(enemy))
	if enemies.is_empty():
		enemiesDefeated.emit()
	
