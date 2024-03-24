extends Node2D

@export var range: float
@export var enemies: Array[Enemy]
@export var cooldown: float

var allEnemies = preload("res://entities/resources/all-enemies.tres")


func _ready():
	$"SpawnTimer".wait_time = cooldown


func _on_spawn_timer_timeout():
	var enemy = enemies.pick_random()
	var enemyScene = preload("res://Entities/enemy.tscn").instantiate()
	enemyScene.enemy = enemy
	enemyScene.global_position = global_position + Vector2(randf_range(-range, range), randf_range(-range, range))
	checkForCollisions(enemyScene.global_position)
	enemyScene.update()
	get_tree().get_root().get_node("Game/Entities").add_child(enemyScene)


func checkForCollisions(point):
	return
	var tilemap = get_tree().get_root().get_node("Game/NavigationRegion2D/Map")
	var tile_size = tilemap.rendering_quadrant_size
	var tile_x = int(point.x / tile_size)
	var tile_y = int(point.y / tile_size)

	# Step 2: Check if the tile at those coordinates has a collidable shape
	# Assuming your tilemap has a method get_collision_shape_at(x, y) which returns the collision shape at the given coordinates
	var collision_shape = tilemap.get_collision_shape_at(tile_x, tile_y)

	# Check if the collision shape exists and if the point is inside it
	if collision_shape and collision_shape.contains(point):
		print("Point is on top of a collidable area of a tile.")
	else:
		print("Point is not on top of a collidable area of a tile.")
