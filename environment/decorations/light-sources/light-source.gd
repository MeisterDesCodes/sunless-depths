extends Node2D


@export var size: float
@export var energy: float
@export var color: Color
@export var shadow: bool

@onready var light: Light2D = get_node("PointLight2D")
@onready var collision: CollisionShape2D = get_node("PointLight2D/Area2D/CollisionShape2D")

var noise = FastNoiseLite.new()
var x = 0


func _ready():
	update(size)
	light.color = color
	light.energy = energy
	RandomNumberGenerator.new().randomize()
	x = randi_range(0, 100)
	light.shadow_enabled = shadow
	collision.disabled = true


func update(size: float):
	light.scale = Vector2(size, size)
	var body = light.get_parent().get_parent().get_parent()
	if body.has_method("isPlayer"):
		light.scale *= body.sightRadiusModifier
		collision.disabled = false


func _process(delta):
	x += 2
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	light.energy = (noise.get_noise_1d(x) * 0.5 + 0.75)


func _on_area_2d_body_entered(body):
	var entity = get_parent().get_parent()
	if entity.sightRadiusEntryEffect != 0:
		if body.has_method("isEnemy"):
			UtilsS.applyStatusEffect(entity, body, UtilsS.setupEffect(preload("res://entities/resources/status-effects/sight-radius-entry.tres"), \
				entity.sightRadiusEntryEffect - 1))
