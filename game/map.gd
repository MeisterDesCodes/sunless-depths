extends TileMap


@export var removeRandomObjects: bool = true


func _ready():
	if !removeRandomObjects:
		return
	
	var lightSourceRemovalChance: float = 0.75
	var lootRemovalChance: float = 0.75
	var resourceNodeRemovalChance: float = 0.5
	var spawnerRemovalChance: float = 0
	
	for object in $"EnvironmentalObjects/Decorations/LightSources".get_children():
		if lightSourceRemovalChance > randf():
			object.queue_free()
	for object in $"EnvironmentalObjects/Decorations/Walls/LightSources".get_children():
		if lightSourceRemovalChance > randf():
			object.queue_free()
			
	for object in $"EnvironmentalObjects/Interactions/Loot".get_children():
		if lootRemovalChance > randf():
			object.queue_free()
	
	for object in $"EnvironmentalObjects/Interactions/ResourceNodes".get_children():
		if resourceNodeRemovalChance > randf():
			object.queue_free()
	
	for object in $"EnvironmentalObjects/Spawners".get_children():
		if spawnerRemovalChance > randf():
			object.queue_free()


func isMap():
	pass
