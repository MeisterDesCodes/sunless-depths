extends Node2D


var range: float = 200
var size = 0.6

func _on_spawn_timer_timeout():
	var node = preload("res://environment/interactions/debris.tscn").instantiate()
	var x = randi_range(global_position.x - range, global_position.x + range)
	var y = randi_range(global_position.y - range, global_position.y + range)
	node.global_position = Vector2(x, y)
	var scale = randf_range(size * 0.75, size * 1.25)
	node.scale = Vector2(scale, scale)
	get_tree().get_root().add_child(node)
