extends Node2D


@onready var enemiesScene = get_tree().get_root().get_node("Game/Entities/Enemies")
@onready var spawnTimer: Timer = get_node("SpawnTimer")

var room: Node2D
var tilemap: TileMap
var currentEnemies: Array[CharacterBody2D] = []

var enemies = preload("res://entities/resources/enemies.tres")
var maxEnemies = 3
var spawnDelay: float


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
	var enemyScene = preload("res://entities/enemy-ui.tscn").instantiate()
	enemyScene.entityResource = pickEntity()#
	enemyScene.global_position = getSpawnPosition().rotated(room.rotation) + room.global_position
	enemiesScene.add_child(enemyScene)
	setTimer()
	currentEnemies.append(enemyScene)
	enemyScene.onDeath.connect(removeEnemy)


func pickEntity():
	var entities: Array[EnemySpawnContainer]
	match LocationLoaderS.currentTier:
		0:
			entities = enemies.allEnemiesTier0
		1:
			entities = enemies.allEnemiesTier1
		2:
			entities = enemies.allEnemiesTier2
		3:
			entities = enemies.allEnemiesTier3
		4:
			entities = enemies.allEnemiesTier4
		5:
			entities = enemies.allEnemiesTier5
	
	var totalScore: int = 0
	for entity in entities:
		totalScore += entity.chance
	
	var index = randf() * totalScore
	var accumulatedScore: float = 0
	for entity in entities:
		if index >= accumulatedScore && index <= accumulatedScore + entity.chance:
				return entity.enemy
		accumulatedScore += entity.chance


func getSpawnPosition():
	var randomTile = tilemap.get_used_cells_by_id(1, 2, Vector2(7, 2), 0).pick_random()
	return tilemap.map_to_local(randomTile)


func removeEnemy(enemyScene: CharacterBody2D):
	currentEnemies = currentEnemies.filter(func(enemy): return enemy != enemyScene)
