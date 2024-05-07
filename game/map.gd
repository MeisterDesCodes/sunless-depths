extends TileMap


@export var removeRandomObjects: bool


func _ready():
	if !removeRandomObjects:
		return
	
	var lightSourceRemovalChance: float = 0
	var spawnerRemovalChance: float = 0
	for object in $"EnvironmentalObjects/Decorations/LightSources".get_children():
		if lightSourceRemovalChance > randf():
			object.queue_free()
	for object in $"EnvironmentalObjects/Decorations/Walls/LightSources".get_children():
		if lightSourceRemovalChance > randf():
			object.queue_free()
	for object in $"EnvironmentalObjects/Spawners".get_children():
		if spawnerRemovalChance > randf():
			object.queue_free()


func isMap():
	pass
