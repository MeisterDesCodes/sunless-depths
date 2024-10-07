extends Node2D


@export var entity: CharacterBody2D

@onready var backgroundMusic = get_node("BackgroundMusic")
@onready var walk = get_node("Walk")
@onready var attack = get_node("Attack")
@onready var hit = get_node("Hit")
@onready var dash = get_node("Dash")
@onready var menu = get_node("Menu")
@onready var hover = get_node("Hover")
@onready var walkTimer = get_node("WalkTimer")


var walkSound: AudioStreamMP3 = preload("res://assets/SFX/step.mp3")
var dashSound: AudioStreamMP3 = preload("res://assets/SFX/dash.mp3")
var meleeAttackSound: AudioStreamMP3 = preload("res://assets/SFX/melee-attack.mp3")
var rangedAttackSound: AudioStreamMP3 = preload("res://assets/SFX/ranged-attack.mp3")
var organicHitSound: AudioStreamMP3 = preload("res://assets/SFX/organic-hit.mp3")
var hoverSound: AudioStreamMP3 = preload("res://assets/SFX/hover.mp3")
var clickSound: AudioStreamMP3 = preload("res://assets/SFX/click.mp3")
var craftSound: AudioStreamMP3 = preload("res://assets/SFX/craft.mp3")
var consumeSound: AudioStreamMP3 = preload("res://assets/SFX/consume.mp3")
var weaponEquipSound: AudioStreamMP3 = preload("res://assets/SFX/equip-weapon.mp3")
var itemEquipSound: AudioStreamMP3 = preload("res://assets/SFX/equip-item.mp3")
var currentStep = 0


func updateWalkTime():
	walkTimer.wait_time = 50 / entity.currentMoveSpeed


func _on_walk_timer_timeout():
	if !entity.has_method("isPlayer"):
		return
	
	updateWalkTime()
	if entity.isWalking:
		playSound(walk, walkSound)


func onAttack(weapon: InventoryWeapon):
	var sound: AudioStreamMP3
	if weapon is MeleeWeapon:
		sound = meleeAttackSound
	else:
		sound = rangedAttackSound
	
	playSound(attack, sound)


func onHit(attack: Attack):
	playSound(hit, organicHitSound)


func onDash():
	playSound(dash, dashSound)


func onHover():
	playSound(hover, hoverSound, true)


func onClick():
	playSound(menu, clickSound, true)


func onCraft():
	playSound(menu, craftSound, true)


func onConsume():
	playSound(menu, consumeSound, true)


func onEquip(item: InventoryResource):
	var sound: AudioStreamMP3
	if item is InventoryWeapon:
		sound = weaponEquipSound
	if item is InventoryEquipment || item is InventoryAmmunition || item is InventoryConsumable:
		sound = itemEquipSound
	
	playSound(menu, sound, true)


func playSound(player: AudioStreamPlayer, sound: AudioStreamMP3, noPitch: bool = false):
	if !noPitch:
		dash.pitch_scale = UtilsS.getRandomRange(1)
	player.stream = sound
	player.play()





