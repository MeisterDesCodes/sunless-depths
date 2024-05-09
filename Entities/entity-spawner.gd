extends Node2D


@export var enemies: Array[Enemy]
@export var spawnDelay: float

@onready var enemiesScene = get_tree().get_root().get_node("Game/Entities/Enemies")
@onready var spawnTimer: Timer = $"SpawnTimer"

var room: Node2D
var tilemap: TileMap
var currentEnemies: Array[CharacterBody2D] = []
var maxEnemies = 4


func setup(_room: Node2D):
	room = _room
	tilemap = _room.get_child(0)
	setTimer()


func setTimer():
	spawnTimer.wait_time = UtilsS.getRandomRange(spawnDelay)
	spawnTimer.start()


func _on_spawn_timer_timeout():
	if currentEnemies.size() < maxEnemies:
		spawnEntity()


func spawnEntity():
	var enemy = enemies.pick_random()
	var enemyScene = preload("res://entities/enemy-ui.tscn").instantiate()
	enemyScene.entityResource = enemy
	enemyScene.global_position = getSpawnPosition().rotated(room.rotation) + room.global_position
	enemiesScene.add_child(enemyScene)
	setTimer()
	currentEnemies.append(enemyScene)
	enemyScene.onDeath.connect(removeEnemy)


func getSpawnPosition():
	var randomTile = tilemap.get_used_cells_by_id(1, 2, Vector2(7, 2), 0).pick_random()
	return tilemap.map_to_local(randomTile)


func removeEnemy(enemyScene: CharacterBody2D):
	currentEnemies = currentEnemies.filter(func(enemy): return enemy != enemyScene)
