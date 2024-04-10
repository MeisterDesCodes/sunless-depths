extends Node2D


var angle: float


func setup(spawnPosition: Vector2, damage: float):
	global_position = spawnPosition
	$"PanelContainer/Label".text = str(round(damage))
	angle = deg_to_rad(randf_range(-50, 50))


func _process(delta):
	position += Vector2.UP.rotated(angle)


func _on_disappear_timer_timeout():
	queue_free()
