extends Node2D


signal enemiesDefeated

@export var lifetime: int
@export var spawners: Node2D

@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var interaction = get_node("Interaction")

var effectAwareness: StatusEffect = preload("res://entities/resources/status-effects/awareness-arena.tres")
var effectSpeed: StatusEffect = preload("res://entities/resources/status-effects/speed-arena.tres")

var enemies: Array[CharacterBody2D]


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	for i in 3:
		await UtilsS.createTimer(0.75)
		for spawner in spawners.get_children():
			spawner.setup(spawners.get_parent().get_parent().get_parent(), 500, 500)
			var enemyScene = spawner.spawnEntity()
			UtilsS.applyStatusEffects(enemyScene, enemyScene, [effectAwareness, effectSpeed])
			enemies.append(enemyScene)
			enemyScene.onDeath.connect(reduceAmount)
			
	game.soundComponent.playArena()


func reduceAmount(enemy: CharacterBody2D):
	enemies.remove_at(enemies.find(enemy))
	if enemies.is_empty():
		enemiesDefeated.emit()
	
