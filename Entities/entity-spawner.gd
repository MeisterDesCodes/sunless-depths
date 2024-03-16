extends Node2D


var allEnemies = preload("res://entities/resources/all-enemies.tres")


func _on_spawn_timer_timeout():
	var enemy = allEnemies.enemies.pick_random()
	var enemyScene = preload("res://Entities/enemy.tscn").instantiate()
	enemyScene.enemy = enemy
	enemyScene.global_position = Vector2(randf_range(-100, -150), randf_range(-50, 0))
	enemyScene.update()
	add_child(enemyScene)
