extends Node2D




func spawnResources(resources: Array[DropResource], spawnType: Enums.resourceSpawnType,
						spawnPosition: Vector2, direction: Vector2, speed: float):
	for resource in resources:
		if resource.dropChance > randf():
			var amount = randi_range(resource.amount * 0.75, resource.amount * 1.25)
			for j in amount:
				var groundResource = preload("res://environment/collectibles/ground-resource.tscn").instantiate()
				groundResource.setup(resource.resource)
				groundResource.global_position = spawnPosition
				groundResource.scale = Vector2(0.5, 0.5)
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
