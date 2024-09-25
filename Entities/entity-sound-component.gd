extends Node2D


@export var entity: CharacterBody2D

@onready var backgroundMusic = get_node("BackgroundMusic")
@onready var walk = get_node("Walk")
@onready var attack = get_node("Attack")
@onready var hit = get_node("Hit")
@onready var dash = get_node("Dash")
@onready var walkTimer = get_node("WalkTimer")


var walkSound: AudioStreamMP3 = preload("res://assets/SFX/step.mp3")
var dashSound: AudioStreamMP3 = preload("res://assets/SFX/dash.mp3")
var meleeAttackSound: AudioStreamMP3 = preload("res://assets/SFX/melee-attack.mp3")
var rangedAttackSound: AudioStreamMP3 = preload("res://assets/SFX/ranged-attack.mp3")
var organicHitSound: AudioStreamMP3 = preload("res://assets/SFX/organic-hit.mp3")
var currentStep = 0


func updateWalkTime():
	walkTimer.wait_time = 50 / entity.currentMoveSpeed


func _on_walk_timer_timeout():
	if !entity.has_method("isPlayer"):
		return
	
	updateWalkTime()
	if entity.isWalking:
		walk.pitch_scale = UtilsS.getRandomRange(1)
		walk.stream = walkSound
		walk.play()


func onAttack(weapon: InventoryWeapon):
	if weapon is MeleeWeapon:
		attack.stream = meleeAttackSound
	else:
		attack.stream = rangedAttackSound
	attack.pitch_scale = UtilsS.getRandomRange(1)
	attack.play()


func onHit(attack: Attack):
	hit.pitch_scale = UtilsS.getRandomRange(1)
	hit.stream = organicHitSound
	hit.play()


func onDash():
	dash.pitch_scale = UtilsS.getRandomRange(1)
	dash.stream = dashSound
	dash.play()
