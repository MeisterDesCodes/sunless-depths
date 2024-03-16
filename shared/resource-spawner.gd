extends Node2D




func spawnResources(resource: InventoryResource, amount: int, spawnType: Enums.resourceSpawnType,
						spawnPosition: Vector2, direction: Vector2, speed: float):
	for i in amount:
		var groundResource = preload("res://environment/collectibles/ground-resource.tscn").instantiate()
		groundResource.setup(resource)
		groundResource.global_position = spawnPosition
		get_tree().get_root().add_child(groundResource)
		
		match spawnType:
			Enums.resourceSpawnType.DASH:
				groundResource.moveSpeed = randf_range(speed * 0.75, speed * 1.25)
				var spreadVector = randf_range(-30, 30)
				groundResource.direction = direction.rotated(deg_to_rad(spreadVector))
				
			Enums.resourceSpawnType.DROP:
				groundResource.moveSpeed = randf_range(speed * 0.75, speed * 1.25)
				var spreadVector = randf_range(-180, 180)
				groundResource.direction = direction.rotated(deg_to_rad(spreadVector))
