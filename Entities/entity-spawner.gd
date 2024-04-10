extends Node2D

@export var range: float
@export var enemies: Array[Entity]
@export var cooldown: float

var allEnemies = preload("res://entities/all-enemies.gd")


func _ready():
	$"SpawnTimer".wait_time = cooldown


func _on_spawn_timer_timeout():
	var enemy = enemies.pick_random()
	var enemyScene = preload("res://entities/enemy-ui.tscn").instantiate()
	enemyScene.enemy = enemy
	enemyScene.global_position = global_position + Vector2(randf_range(-range, range), randf_range(-range, range))
	enemyScene.update()
	get_tree().get_root().get_node("Game/Entities").add_child(enemyScene)
