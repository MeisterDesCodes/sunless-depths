extends Control


@onready var game: Node2D = get_tree().get_root().get_node("GameController/Game")
@onready var location: Label = get_node("PanelContainer/Location")
@onready var particles: Node2D = get_node("Particles")
@onready var particle1: GPUParticles2D = get_node("Particles").get_child(0).get_child(0)
@onready var particle2: GPUParticles2D = get_node("Particles").get_child(1).get_child(0)


func _ready():
	particles.global_position.x = DisplayServer.screen_get_size().x / 2
	particle1.emitting = false
	particle2.emitting = false


func setup(text: String):
	location.text = text
	game.soundComponent.playDiscovery()
	
	await UtilsS.createTimer(0.15)
	particle1.emitting = true
	particle2.emitting = true
	
	await UtilsS.createTimer(2.5)
	particle1.emitting = false
	particle2.emitting = false
	
	await UtilsS.createTimer(0.25)
	location.text = ""
	UILoaderS.closeUIOverlay(self)
