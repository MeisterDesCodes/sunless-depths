extends Node2D


var projectileScene: PackedScene = preload("res://weapons/projectile-ui.tscn")


func spawnProjectiles(caster: CharacterBody2D, _projectile: Projectile, _position: Vector2, _direction, _spread, projectileAmount: int):
	for projectile in projectileAmount:
		var projectileInstance = projectileScene.instantiate()
		if (get_tree()):
			get_tree().get_root().add_child(projectileInstance)
		
		var spreadVector = randf_range(-_spread / 2, _spread / 2)
		var direction = _direction.rotated(deg_to_rad(spreadVector))
		projectileInstance.setup(caster, _projectile, _position, direction)
