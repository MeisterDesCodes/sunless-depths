extends Node2D


@export var energy: float
@export var color: Color

@onready var light = $"PointLight2D"

var noise = FastNoiseLite.new()
var x = 0


func _ready():
	light.color = color
	light.energy = energy
	RandomNumberGenerator.new().randomize()
	x = randi_range(0, 100)


func _process(delta):
	x += 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	light.energy = (noise.get_noise_1d(x) / 2 + 1)

