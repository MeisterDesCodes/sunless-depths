extends Node2D


@export var size: float
@export var energy: float
@export var color: Color
@export var shadow: bool

@onready var light = $"PointLight2D"

var noise = FastNoiseLite.new()
var x = 0


func _ready():
	update(size)
	light.color = color
	light.energy = energy
	RandomNumberGenerator.new().randomize()
	x = randi_range(0, 100)
	light.shadow_enabled = shadow


func update(size: float):
	light.scale = Vector2(size, size)
	var body = light.get_parent().get_parent().get_parent()
	if body.has_method("isPlayer"):
		light.scale *= body.sightRadiusModifier


func _process(delta):
	x += 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	light.energy = (noise.get_noise_1d(x) * 0.75 + 1)

