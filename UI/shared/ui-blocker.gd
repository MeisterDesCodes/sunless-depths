extends TextureRect


var currentThreshold: float = 0.25


func _process(delta):
	currentThreshold += 1.5 * delta
	material.set_shader_parameter("dissolve_threshold", currentThreshold)
