extends Node2D


@onready var noise = FastNoiseLite.new()
@onready var light = $"PointLight2D"

var x = 0


func _process(delta):
	x += 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	light.energy = (noise.get_noise_1d(x) + 1)

