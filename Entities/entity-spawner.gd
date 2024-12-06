extends Node2D


@export var spawnAtLocation: bool = false

@onready var enemiesScene = get_tree().get_root().get_node("GameController/Game/NavigationRegion2D/CaveGenerator").get_child(1)
@onready var spawnTimer: Timer = get_node("SpawnTimer")

var room: Node2D
var tilemap: TileMap
var currentEnemies: Array[CharacterBody2D] = []

var enemies = preload("res://entities/resources/enemies.tres")
var spawnDelay: float
var maxEnemies: int


func setup(_room: Node2D, _spawnDelay: float, _maxEnemies: int):
	room = _room
	spawnDelay = _spawnDelay
	maxEnemies = _maxEnemies
	tilemap = _room.get_child(0)
	setTimer()


func setTimer():
	spawnTimer.wait_time = UtilsS.getRandomRange(spawnDelay)
	spawnTimer.start()


func _on_spawn_timer_timeout():
	if currentEnemies.size() < maxEnemies && !spawnAtLocation:
		spawnEntity()


func spawnEntity():
	var enemyScene = preload("res://entities/enemy-ui.tscn").instantiate()
	enemyScene.entityResource = pickEntity()
	
	var _position: Vector2
	if spawnAtLocation:
		_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	else:
		_position = getSpawnPosition().rotated(room.rotation) + room.global_position
	enemyScene.global_position = _position
	
	enemiesScene.add_child(enemyScene)
	setTimer()
	currentEnemies.append(enemyScene)
	enemyScene.onDeath.connect(removeEnemy)
	
	return enemyScene


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
				return entity.enemy.duplicate()
		accumulatedScore += entity.chance


func getSpawnPosition():
	var randomTile = tilemap.get_used_cells_by_id(1, 2, Vector2(7, 2), 0).pick_random()
	return tilemap.map_to_local(randomTile)


func removeEnemy(enemyScene: CharacterBody2D):
	currentEnemies = currentEnemies.filter(func(enemy): return enemy != enemyScene)
