extends Marker2D



func _process(delta):
	rotation = lerp_angle(rotation, (get_global_mouse_position() - global_position).normalized().angle(), 0.1)
