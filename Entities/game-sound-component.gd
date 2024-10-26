extends Node2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var ambientPlayer = get_node("AmbientMusic")
@onready var effectPlayer = get_node("EffectMusic")
@onready var ambientEffectPlayer = get_node("AmbientEffectMusic")
@onready var ambientTimer = get_node("AmbientTimer")
@onready var fadeoutTimer = get_node("FadeoutTimer")

var ambientCaveMusic: Array[AudioStreamMP3] = [preload("res://assets/music/background/cave-ambient.mp3"),
	preload("res://assets/music/background/cave-ambient-2.mp3")]
var ambientSettlementMusic: Array[AudioStreamMP3] = [preload("res://assets/music/background/settlement-ambient.mp3")]
var effectMusic: Array[AudioStreamMP3] = [preload("res://assets/music/effects/regular/water-droplets.mp3"),
	preload("res://assets/music/effects/regular/eerie-sound.mp3"), preload("res://assets/music/effects/regular/abyss.mp3"),
	preload("res://assets/music/effects/regular/devil-laugther.mp3"), preload("res://assets/music/effects/regular/scream.mp3"),
	preload("res://assets/music/effects/regular/desolation.mp3"), preload("res://assets/music/effects/regular/mystery.mp3")]
var discoveryMusic: AudioStreamMP3 = preload("res://assets/music/effects/event/discovery.mp3")
var arenaMusic: AudioStreamMP3 = preload("res://assets/music/effects/event/arena.mp3")

var effectDelay: float = 20


func _ready():
	ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay)
	ambientTimer.start()


func playSettlementAmbient():
	playMusic(ambientPlayer, ambientSettlementMusic)


func playCaveAmbient():
	playMusic(ambientPlayer, ambientCaveMusic)


func playCaveAmbientEffect():
	playMusic(ambientEffectPlayer, effectMusic)


func playDiscovery():
	playMusic(effectPlayer, [discoveryMusic])


func playArena():
	playMusic(effectPlayer, [arenaMusic])


func playMusic(player: AudioStreamPlayer, musicArray: Array[AudioStreamMP3]):
	player.stop()
	player.stream = musicArray[randi_range(0, musicArray.size() - 1)]
	ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay) + player.stream.get_length()
	player.play()


func _on_ambient_timer_timeout():
	if playerScene.isInCave:
		playCaveAmbientEffect()


func _on_ambient_music_finished():
	if playerScene.isInCave:
		playCaveAmbient()
	else:
		playSettlementAmbient()
