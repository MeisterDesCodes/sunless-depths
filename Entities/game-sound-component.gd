extends Node2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var ambientPlayer = get_node("AmbientMusic")
@onready var effectPlayer = get_node("EffectMusic")
@onready var ambientTimer = get_node("AmbientTimer")

var ambientCaveMusic: Array[AudioStreamMP3] = [preload("res://assets/music/ambient/cave-ambient.mp3"),
	preload("res://assets/music/ambient/cave-ambient-2.mp3")]
var ambientSettlementMusic: Array[AudioStreamMP3] = [preload("res://assets/music/ambient/settlement-ambient.mp3")]
var effectMusic: Array[AudioStreamMP3] = [preload("res://assets/music/effect/water-droplets.mp3"),
	preload("res://assets/music/effect/eerie-sound.mp3"), preload("res://assets/music/effect/abyss.mp3"),
	preload("res://assets/music/effect/devil-laugther.mp3"), preload("res://assets/music/effect/scream.mp3"),
	preload("res://assets/music/effect/alien-sound.mp3")]

var effectDelay: float = 30


func _ready():
	ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay)
	ambientTimer.start()


func playSettlementAmbient():
	playMusic(ambientPlayer, ambientSettlementMusic)


func playCaveAmbient():
	playMusic(ambientPlayer, ambientCaveMusic)


func playCaveEffect():
	playMusic(effectPlayer, effectMusic)


func playMusic(player: AudioStreamPlayer, musicArray: Array[AudioStreamMP3]):
	if !player.playing:
		AnimationsS.fadeSound(player, -30, 2)
		await get_tree().create_timer(2).timeout
	AnimationsS.fadeSound(player, -10, 2)
	player.stream = musicArray[randi_range(0, musicArray.size() - 1)]
	player.play()


func _on_ambient_timer_timeout():
	if playerScene.isInCave:
		ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay)
		playCaveEffect()


func _on_ambient_music_finished():
	if playerScene.isInCave:
		playCaveAmbient()
	else:
		playSettlementAmbient()
