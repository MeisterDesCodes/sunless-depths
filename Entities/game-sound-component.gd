extends Node2D


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var ambientPlayer = get_node("AmbientMusic")
@onready var effectPlayer = get_node("EffectMusic")
@onready var ambientTimer = get_node("AmbientTimer")
@onready var fadeoutTimer = get_node("FadeoutTimer")

var ambientCaveMusic: Array[AudioStreamMP3] = [preload("res://assets/music/ambient/cave-ambient.mp3"),
	preload("res://assets/music/ambient/cave-ambient-2.mp3")]
var ambientSettlementMusic: Array[AudioStreamMP3] = [preload("res://assets/music/ambient/settlement-ambient.mp3")]
var effectMusic: Array[AudioStreamMP3] = [preload("res://assets/music/effect/water-droplets.mp3"),
	preload("res://assets/music/effect/eerie-sound.mp3"), preload("res://assets/music/effect/abyss.mp3"),
	preload("res://assets/music/effect/devil-laugther.mp3"), preload("res://assets/music/effect/scream.mp3"),
	preload("res://assets/music/effect/alien-sound.mp3")]
var discoveryMusic: AudioStreamMP3 = preload("res://assets/music/effect/discorvery.mp3")
var arenaMusic: AudioStreamMP3 = preload("res://assets/music/effect/arena.mp3")

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


func playDiscovery():
	playMusic(effectPlayer, [discoveryMusic])


func playArena():
	playMusic(effectPlayer, [arenaMusic])


func playMusic(player: AudioStreamPlayer, musicArray: Array[AudioStreamMP3]):
	#if !player.playing:
	#	AnimationsS.fadeSound(player, -30, 1)
	#	await get_tree().create_timer(1).timeout
	AnimationsS.fadeSound(player, -10, 1)
	player.stop()
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


func _on_fadeout_timer_timeout():
	if effectPlayer.stream:
		var remainingTime = effectPlayer.stream.get_length() - effectPlayer.get_playback_position()
		if remainingTime < 1:
			AnimationsS.fadeSound(effectPlayer, -30, 1)
