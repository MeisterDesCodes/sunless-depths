extends StaticBody2D

@onready var noise = FastNoiseLite.new()
@onready var light = $"PointLight2D"
var x = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#noise.frequency = 0
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	x += 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	light.energy = (noise.get_noise_1d(x) + 1)

