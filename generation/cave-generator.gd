@tool
extends Node2D


@export var generate: bool:
	set(value):
		generateCave()
@export var iterations: int

var rooms = [preload("res://generation/room-1.tscn"),
preload("res://generation/corridor-1.tscn"),
preload("res://generation/corridor-2.tscn")]
var currentRooms: Array[Node2D]
var tileSize = 64
var counter: int = 0


	#preload("res://generation/corridors/corridor-1/corridor-1-0.tscn"),
	#preload("res://generation/corridors/corridor-1/corridor-1-90.tscn"),
	#preload("res://generation/corridors/corridor-1/corridor-1-180.tscn"),
	#preload("res://generation/corridors/corridor-1/corridor-1-270.tscn")

func generateCave():
	clearCave()
	generateRoot()
	generateRooms()


func clearCave():
	counter = 0
	currentRooms = []
	for child in get_children():
		remove_child(child)


func instanceRoom():
	return rooms.pick_random().instantiate().duplicate()


func generateRoot():
	var root = instanceRoom()
	add_child(root)
	root.global_position = Vector2(0, 0)
	currentRooms.append(root)


func generateFittingRoom(exit):
	var newRoom = rooms.filter(func(room): return roomHasDirection(room, exit.direction)).pick_random().instantiate().duplicate()
	return newRoom


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


func roomHasDirection(room, direction):
	var roomInstance = room.instantiate()
	return !roomInstance.exits.filter(func(exit): return exit.direction == direction).is_empty()


func generateRooms():
	for n in iterations:
		var remainingExits: Array = getRemainingExits()
		for exit in remainingExits:
			var room = generateFittingRoom(exit)
			print(n)
			if room:
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
						
				room.global_position = Vector2(exitX, exitY) + getRoomFromExit(exit).global_position
				
				if !checkForCollisions(room):
					exit.completed = true
					roomExit.completed = true
					add_child(room)
					currentRooms.append(room)


func getRemainingExits():
	var remainingExits: Array = []
	for room in currentRooms:
		for exit in room.exits:
			if !exit.completed:
				remainingExits.append(exit)
	print(remainingExits)
	return remainingExits


func getRoomFromExit(exit):
	return currentRooms.filter(func(room): return exit in room.exits)[0]


func findExit(room, direction):
	return room.exits.filter(func(exit): return exit.direction == direction)[0]







