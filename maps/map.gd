extends TileMap


func _ready():
	var chance: float = 0.35
	for object in $"EnvironmentalObjects/Decorations/LightSources".get_children():
		if randf() < chance:
			object.queue_free()
	for object in $"EnvironmentalObjects/Decorations/Walls/LightSources".get_children():
		if randf() < chance:
			object.queue_free()


func isMap():
	pass
