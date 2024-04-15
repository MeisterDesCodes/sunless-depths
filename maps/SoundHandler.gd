extends Node2D


@export var player: CharacterBody2D

@onready var backgroundMusic = get_node("BackgroundMusic")
@onready var sfx = get_node("SFX")
@onready var walkTimer = get_node("WalkTimer")


var steps: Array[AudioStreamMP3] = [preload("res://assets/SFX/step-1.mp3"), preload("res://assets/SFX/step-2.mp3"),
	preload("res://assets/SFX/step-3.mp3"), preload("res://assets/SFX/step-4.mp3")]
var currentStep = 0

func _ready():
	updateWalkTime()


func _on_walk_timer_timeout():
	updateWalkTime()
	walkTimer.start()
	if player.isWalking:
		sfx.stream = steps[currentStep % steps.size()]
		sfx.play()
		currentStep += 1
	else:
		currentStep = 0
		resetWalkTime()


func updateWalkTime():
	walkTimer.wait_time = 50 / player.currentMoveSpeed


func resetWalkTime():
	walkTimer.wait_time = 0






