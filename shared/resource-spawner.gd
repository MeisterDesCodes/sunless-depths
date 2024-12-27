extends Node2D


@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")

var gold = preload("res://inventory-resource/resources/material/primary/gold.tres")
var experience = preload("res://inventory-resource/resources/material/primary/experience.tres")
var goldThresholds: Array[int] = [1, 5, 10, 20, 50, 100]
var experienceThresholds: Array[int] = [1, 10, 20, 50, 100, 200]


func spawnResources(resources: Array[DropResource], spawnType: Enums.resourceSpawnType,
						spawnPosition: Vector2, direction: Vector2, speed: float):
	
	for resource in resources.duplicate():
		resource.amount = round(resource.amount * playerScene.lootModifier)
	
	var goldResources = getResourceDistribution(resources.filter(func(resource): return resource.resource.name == gold.name), goldThresholds)
	var experienceResources = getResourceDistribution(resources.filter(func(resource): return resource.resource.name == experience.name), experienceThresholds)
	var otherResources = resources.filter(func(resource): return resource.resource != gold && resource.resource != experience)
	
	resources = []
	resources.append_array(goldResources)
	resources.append_array(experienceResources)
	resources.append_array(otherResources)
	for resource in resources:
		spawnResource(resource, spawnType, spawnPosition, direction, speed, false)


func spawnResource(resource: DropResource, spawnType: Enums.resourceSpawnType,
						spawnPosition: Vector2, direction: Vector2, speed: float, wasDropped: bool):
	if resource.dropChance > randf():
		var amount: int
		if !wasDropped:
			amount = round(randf_range(resource.amount * UtilsS.randomRangeMin, resource.amount * UtilsS.randomRangeMax))
		else:
			amount = resource.amount
		
		for j in amount:
			var groundResource = preload("res://environment/collectibles/ground-resource.tscn").instantiate()
			groundResource.setup(resource.resource, wasDropped)
			groundResource.global_position = spawnPosition
			groundResource.scale = Vector2(0.5, 0.5)
			game.groundResources.add_child(groundResource)
			
			var spreadVector: float
			match spawnType:
				Enums.resourceSpawnType.DASH:
					spreadVector = randf_range(-30, 30)
				
				Enums.resourceSpawnType.DROP:
					spreadVector = randf_range(-180, 180)
				
			groundResource.moveSpeed = randf_range(speed * UtilsS.randomRangeMin, speed * UtilsS.randomRangeMin)
			groundResource.direction = direction.rotated(deg_to_rad(spreadVector))


func getResourceDistribution(resources, thresholds):
	if resources.is_empty():
		return []
	
	var resource = resources[0]
	var newResources: Array = []
	var totalAmount = resource.amount
	while totalAmount > 0:
		var amount = 0
		for threshold in thresholds:
			if totalAmount >= threshold:
				amount = threshold
			
		totalAmount -= amount
		var newResource
		match(resource.resource.name):
			gold.name:
				newResource = preload("res://inventory-resource/resources/material/primary/gold.tres").duplicate()
			experience.name:
				newResource = preload("res://inventory-resource/resources/material/primary/experience.tres").duplicate()
		
		newResource.pickupAmount = amount
		newResources.append(newResource)
		
	var dropResources: Array = []
	for newResource in newResources:
		var dropResource = DropResource.new()
		dropResource.resource = newResource
		dropResource.amount = 1
		dropResource.dropChance = 1
		dropResources.append(dropResource)
		
	return dropResources












