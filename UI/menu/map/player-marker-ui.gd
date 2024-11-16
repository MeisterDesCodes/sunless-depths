extends Control

@onready var marker1: PanelContainer = get_node("PanelContainer")
@onready var marker2: PanelContainer = get_node("PanelContainer2")
@onready var particles: Node2D = get_node("EffectParticles")


func _ready():
	particles.get_child(0).scale = Vector2(2, 2)
	particles.get_child(0).self_modulate = UtilsS.colorPrimary
	particles.get_child(0).emitting = true


func _process(delta):
	marker1.rotation += 0.025
	marker2.rotation -= 0.025
