extends PanelContainer

@onready var particles: Node2D = get_node("EffectParticles")


func _ready():
	particles.get_child(0).emitting = true


func _process(delta):
	rotation += 0.025
