@tool
extends Node2D


signal spawnPlayer

@export var generate: bool:
	set(value):
		generateCave()

@export var iterations: int
@export var caveVariation: Enums.caveVariations

@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var enemiesScene = get_tree().get_root().get_node("GameController/Game/Entities/Enemies")
@onready var cave = get_node("Cave")

@onready var tileSize: int = 64
@onready var availableDirections: Array[Enums.exitDirection] = [Enums.exitDirection.LEFT, Enums.exitDirection.RIGHT]
@onready var initialDirection: Enums.exitDirection = Enums.exitDirection.LEFT

var currentRooms: Array[Node2D]
var tier: int

var rooms: Array[PackedScene] = preload("res://generation/rooms/rooms.tres").allSegments
var rootRoomsSmall: Array[PackedScene] = preload("res://generation/rooms/root-rooms-small.tres").allSegments
var rootRoomsLarge: Array[PackedScene] = preload("res://generation/rooms/root-rooms-large.tres").allSegments
var corridors: Array[PackedScene] = preload("res://generation/corridors/corridors.tres").allSegments
var dead_ends: Array[PackedScene] = preload("res://generation/dead-ends/dead-ends.tres").allSegments
var exits: Array[PackedScene] = preload("res://generation/exits/exits.tres").allSegments
var specialExits: Array[PackedScene] = preload("res://generation/exits/special-exits.tres").allSegments
var specialRooms: Array[PackedScene] = preload("res://generation/special/special-rooms.tres").allSegments
var specialRoomsDeadEnd: Array[PackedScene] = preload("res://generation/special/special-rooms-dead-end.tres").allSegments

var oldTomsWorkshop: PackedScene = preload("res://generation/corridors/corridor-wooden/corridor-wooden-90.tscn")

var generatedSpecialRooms: Array[Node2D] = []
var generatedExits: Array[Node2D] = []

var placedSpecialRooms: int = 0
var placedSpecialRoomsDeadEnd: int = 0

var maxSpecialRooms: int = 0
var maxSpecialRoomsDeadEnd: int = 0


func generateCave():
	maxSpecialRooms = iterations - 1
	maxSpecialRoomsDeadEnd = iterations - 1
	
	clearCave()
	if iterations > 0:
		generateRoot()
		generateRooms()
		setSpawners()
		validateCave()


func clearCave():
	cave.global_position = Vector2.ZERO
	print(cave.global_position)
	
	placedSpecialRooms = 0
	placedSpecialRoomsDeadEnd = 0
	
	currentRooms.clear()
	generatedSpecialRooms.clear()
	generatedExits.clear()
	
	for child in cave.get_children():
		cave.remove_child(child)
	for enemy in enemiesScene.get_children():
		enemiesScene.remove_child(enemy)


func generateRoot():
	var root
	if iterations == 1:
		root = rootRoomsSmall.pick_random().instantiate().duplicate()
	else:
		root = rootRoomsLarge.pick_random().instantiate().duplicate()
	
	match caveVariation:
		Enums.caveVariations.NONE:
			pass
		Enums.caveVariations.OLD_TOMS_WORKSHOP:
			root = oldTomsWorkshop.instantiate().duplicate()
			exits = specialExits
	
	cave.add_child(root)
	root.global_position = Vector2.ZERO
	currentRooms.append(root)


func generateFittingRoom(exit, roomType):
	for n in 5:
		var direction: Enums.exitDirection
		match exit.direction:
			Enums.exitDirection.TOP:
				direction = Enums.exitDirection.DOWN
			Enums.exitDirection.RIGHT:
				direction = Enums.exitDirection.LEFT
			Enums.exitDirection.DOWN:
				direction = Enums.exitDirection.TOP
			Enums.exitDirection.LEFT:
				direction = Enums.exitDirection.RIGHT
				
		var chance = randf()
		var segments
		var repeatingCorridorChance = 0.25
		var specialRoomChance = 0.35
		
		match roomType:
			Enums.segmentType.ROOM:
				if exit.room.type == Enums.segmentType.ROOM || chance < repeatingCorridorChance:
					segments = corridors
				else:
					if chance < specialRoomChance && placedSpecialRooms < maxSpecialRooms:
						segments = specialRooms
					else:
						segments = rooms
				
			Enums.segmentType.DEAD_END:
				segments = dead_ends
				
			Enums.segmentType.EXIT:
				segments = exits
				
			Enums.segmentType.SPECIAL_ROOM_DEAD_END:
				segments = specialRoomsDeadEnd
		
		var filteredSegments = segments.filter(func(segment): return segmentHasDirection(segment, direction))
		if !filteredSegments.is_empty():
			var newRoom = filteredSegments.pick_random().instantiate().duplicate()
			cave.add_child(newRoom)
			setRoomPosition(newRoom, exit)
			if !checkForCollisions(newRoom) || roomType == Enums.segmentType.DEAD_END:
				return newRoom
			else:
				cave.remove_child(newRoom)
	
	return null


func checkForCollisions(room):
	var isColliding: bool = false
	for targetRoom in currentRooms:
		var newRoomShape: RectangleShape2D = room.get_child(1).get_child(0).shape
		var targetRoomShape: RectangleShape2D = targetRoom.get_child(1).get_child(0).shape
		var newRoomX = room.global_position.x
		var newRoomY = room.global_position.y
		var newRoomW = newRoomShape.extents.x * 2
		var newRoomH = newRoomShape.extents.y * 2
		var targetRoomX = targetRoom.global_position.x
		var targetRoomY = targetRoom.global_position.y
		var targetRoomW = targetRoomShape.extents.x * 2
		var targetRoomH = targetRoomShape.extents.y * 2
		
		var collision: bool = newRoomX < targetRoomX + targetRoomW && \
		newRoomX + newRoomW > targetRoomX && \
		newRoomY < targetRoomY + targetRoomH && \
		newRoomY + newRoomH > targetRoomY
		
		if collision:
			isColliding = true
		
	return isColliding


func segmentHasDirection(segment, direction):
	var segmentInstance = segment.instantiate()
	return !segmentInstance.exits.filter(func(exit): return exit.direction == direction).is_empty()


func setRoomPosition(room, exit):
	var roomExit
	var exitX = exit.position.x * tileSize
	var exitY = exit.position.y * tileSize
	match exit.direction:
		Enums.exitDirection.TOP:
			roomExit = findExit(room, Enums.exitDirection.DOWN)
			exitX -= roomExit.position.x * tileSize
			exitY -= (roomExit.position.y + 1) * tileSize
		Enums.exitDirection.LEFT:
			roomExit = findExit(room, Enums.exitDirection.RIGHT)
			exitX -= (roomExit.position.x + 1) * tileSize
			exitY -= roomExit.position.y * tileSize
		Enums.exitDirection.DOWN:
			roomExit = findExit(room, Enums.exitDirection.TOP)
			exitX -= roomExit.position.x * tileSize
			exitY += tileSize
		Enums.exitDirection.RIGHT:
			roomExit = findExit(room, Enums.exitDirection.LEFT)
			exitX += tileSize
			exitY -= roomExit.position.y * tileSize
	
	room.global_position = Vector2(exitX, exitY) + exit.room.global_position


func calculateRoomExit(room, exit):
	var roomExit
	match exit.direction:
		Enums.exitDirection.TOP:
			roomExit = findExit(room, Enums.exitDirection.DOWN)
		Enums.exitDirection.LEFT:
			roomExit = findExit(room, Enums.exitDirection.RIGHT)
		Enums.exitDirection.DOWN:
			roomExit = findExit(room, Enums.exitDirection.TOP)
		Enums.exitDirection.RIGHT:
			roomExit = findExit(room, Enums.exitDirection.LEFT)
	return roomExit


func generateRooms():
	for n in iterations - 1:
		for exit in getRemainingExits():
			placeRoom(exit, Enums.segmentType.ROOM)
	
	generateExits()
	generateDeadEndSpecialRooms()
	generateDeadEnds()


func placeRoom(exit, type: Enums.segmentType):
	var room = generateFittingRoom(exit, type)
	if room:
		exit.completed = true
		calculateRoomExit(room, exit).completed = true
		currentRooms.append(room)
	
	return room


func generateExits():
	for direction in availableDirections:
		var exit = generateExitInDirection(getRemainingExits(), direction)


func filterExitsByDirection(exits, direction: Enums.exitDirection):
	match direction:
		Enums.exitDirection.TOP:
			return exits.filter(func(exit): return getExitGlobalPosition(exit).y < 0)
		Enums.exitDirection.RIGHT:
			return exits.filter(func(exit): return getExitGlobalPosition(exit).x > 0)
		Enums.exitDirection.DOWN:
			return exits.filter(func(exit): return getExitGlobalPosition(exit).y > 0)
		Enums.exitDirection.LEFT:
			return exits.filter(func(exit): return getExitGlobalPosition(exit).x < 0)


func generateExitInDirection(exits, direction):
	if exits.is_empty():
		return
	
	var foundExit
	#for exit in exits:
	#	match direction:
	#		Enums.exitDirection.TOP:
	#			if !foundExit || getExitGlobalPosition(exit).y < getExitGlobalPosition(foundExit).y:
	#				foundExit = exit
	#		Enums.exitDirection.RIGHT:
	#			if !foundExit || getExitGlobalPosition(exit).x > getExitGlobalPosition(foundExit).x:
	#				foundExit = exit
	#		Enums.exitDirection.DOWN:
	#			if !foundExit || getExitGlobalPosition(exit).y > getExitGlobalPosition(foundExit).y:
	#				foundExit = exit
	#		Enums.exitDirection.LEFT:
	#			if !foundExit || getExitGlobalPosition(exit).x < getExitGlobalPosition(foundExit).x:
	#				foundExit = exit
	
	foundExit = filterExitsByDirection(exits, direction).pick_random()
	var room = placeRoom(foundExit, Enums.segmentType.EXIT)
	if room:
		generatedExits.append(room)
		var foundExitTemplate = room.get_child(0)
		foundExitTemplate.exit.direction = direction
		foundExitTemplate.exit.update()
		if direction == initialDirection:
			spawnPlayer.emit(foundExitTemplate.playerSpawner.global_position)


func getExitGlobalPosition(exit):
	return exit.room.global_position + exit.position * tileSize


func generateDeadEnds():
	for exit in getRemainingExits():
		generateDeadEnd(exit, Enums.segmentType.DEAD_END)


func generateDeadEndSpecialRooms():
	var specialRoomsDeadEndChance: float = 0.35
	for exit in getRemainingExits():
		if randf() < specialRoomsDeadEndChance && placedSpecialRoomsDeadEnd < maxSpecialRoomsDeadEnd:
			if placeRoom(exit, Enums.segmentType.SPECIAL_ROOM_DEAD_END):
				placedSpecialRoomsDeadEnd += 1


func generateDeadEnd(exit, type: Enums.segmentType):
	var room = generateFittingRoom(exit, type)
	if room:
		currentRooms.append(room)


func getRemainingExits():
	var remainingExits: Array = []
	for room in currentRooms:
		for exit in room.exits:
			exit.room = room
			if !exit.completed:
				remainingExits.append(exit)
	return remainingExits


func findExit(room, direction):
	return room.exits.filter(func(exit): return exit.direction == direction)[0]


func setSpawners():
	for room in currentRooms:
		var spawners: Node2D = room.get_child(0).get_node("Map/EnvironmentalObjects/Spawners")
		for spawner in spawners.get_children():
			spawner.setup(room.get_child(0), 40 - tier * 5, 2 + tier)
			spawner.spawnEntity()


func validateCave():
	if generatedExits.size() < availableDirections.size():
		generateCave()
	else:
		saveCave()


func saveCave():
	for room in cave.get_children():
		room.id = randi() % 10000
	LocationLoaderS.currentCave = cave



