@tool
extends Node2D


@export var generate: bool:
	set(value):
		generateCave()
@export var iterations: int

@onready var cave = get_node("Cave")

var rooms: Array[PackedScene] = preload("res://generation/rooms/rooms.tres").allSegments
var corridors: Array[PackedScene] = preload("res://generation/corridors/corridors.tres").allSegments
var dead_ends: Array[PackedScene] = preload("res://generation/dead-ends/dead-ends.tres").allSegments

var currentRooms: Array[Node2D]
var tileSize = 64


func generateCave():
	clearCave()
	generateRoot()
	generateRooms()


func clearCave():
	currentRooms = []
	for child in cave.get_children():
		cave.remove_child(child)


func instanceRoom():
	return rooms.pick_random().instantiate().duplicate()


func generateRoot():
	if iterations > 0:
		var root = instanceRoom()
		cave.add_child(root)
		root.global_position = Vector2(0, 0)
		currentRooms.append(root)


func generateFittingRoom(exit, roomType):
	for n in 1:
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
				
		var type = getRoomFromExit(exit).type
		var chance = randf()
		var segments
		var chanceThreshold = 0.1
		if type == Enums.segmentType.CORRIDOR:
			segments = rooms if chance > chanceThreshold else corridors
		else:
			segments = corridors if chance > chanceThreshold else rooms
		
		if roomType == Enums.segmentType.DEAD_END:
			segments = dead_ends
		
		var newRoom = segments.filter(func(room): return segmentHasDirection(room, direction)).pick_random().instantiate().duplicate()
		print(newRoom)
		cave.add_child(newRoom)
		setRoomPosition(newRoom, exit)
		if !checkForCollisions(newRoom) || roomType == Enums.segmentType.DEAD_END:
		#if true:
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
	#room.global_position = Vector2(0, 0)
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
		
	#print(roomExit)
	#print(exitX)
	#print(exitY)
	#print(getRoomFromExit(exit).global_position)
	#print(room.global_position)
	room.global_position = Vector2(exitX, exitY) + getRoomFromExit(exit).global_position


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
	for n in iterations:
		for exit in getRemainingExits():
			var room = generateFittingRoom(exit, Enums.segmentType.ROOM)
			if room:
				exit.completed = true
				calculateRoomExit(room, exit).completed = true
				#print(room.global_position)
				#cave.add_child(room)
				#setRoomPosition(room, exit)
				currentRooms.append(room)
	
	print(getRemainingExits())
	for exit in getRemainingExits():
		var room = generateFittingRoom(exit, Enums.segmentType.DEAD_END)
		if room:
			currentRooms.append(room)


func getRemainingExits():
	var remainingExits: Array = []
	for room in currentRooms:
		for exit in room.exits:
			if !exit.completed:
				remainingExits.append(exit)
	return remainingExits


func getRoomFromExit(exit):
	#Bug
	var test = currentRooms.filter(func(room): return exit in room.exits)
	print(test)
	return test[0]


func findExit(room, direction):
	return room.exits.filter(func(exit): return exit.direction == direction)[0]







