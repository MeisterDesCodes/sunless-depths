extends Node2D


@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var ambientPlayer = get_node("AmbientMusic")
@onready var effectPlayer = get_node("EffectMusic")
@onready var ambientEffectPlayer = get_node("AmbientEffectMusic")
@onready var ambientTimer = get_node("AmbientTimer")
@onready var fadeoutTimer = get_node("FadeoutTimer")

var caveAmbientMusic: Array[AudioStreamMP3] = [preload("res://assets/music/background/cave/dark-fear.mp3"), \
	preload("res://assets/music/background/cave/dark-wet.mp3")]
var effectMusic: Array[AudioStreamMP3] = [preload("res://assets/music/effects/regular/water-droplets.mp3"),
	preload("res://assets/music/effects/regular/eerie-sound.mp3"), preload("res://assets/music/effects/regular/abyss.mp3"),
	preload("res://assets/music/effects/regular/devil-laugther.mp3"), preload("res://assets/music/effects/regular/scream.mp3"),
	preload("res://assets/music/effects/regular/desolation.mp3"), preload("res://assets/music/effects/regular/mystery.mp3")]
var discoveryMusic: AudioStreamMP3 = preload("res://assets/music/effects/event/discovery.mp3")
var arenaMusic: AudioStreamMP3 = preload("res://assets/music/effects/event/arena.mp3")

var effectDelay: float = 30


func _ready():
	ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay)
	ambientTimer.start()


func playSettlementAmbient(location: MapLocation):
	playMusic(ambientPlayer, location.ambientMusic)


func playCaveAmbient(pathway: MapPathway):
	if pathway.ambientMusic.size() > 0:
		playMusic(ambientPlayer, pathway.ambientMusic)
	else:
		playMusic(ambientPlayer, caveAmbientMusic)


func playDiscovery():
	playMusic(effectPlayer, [discoveryMusic])


func playArena():
	playMusic(effectPlayer, [arenaMusic])


func playMusic(player: AudioStreamPlayer, musicArray: Array[AudioStreamMP3]):
	player.stop()
	player.stream = musicArray.pick_random()
	ambientTimer.wait_time = UtilsS.getRandomRange(effectDelay)
	player.play()


func _on_ambient_timer_timeout():
	if playerScene.isInCave:
		playMusic(ambientEffectPlayer, effectMusic)


func _on_ambient_music_finished():
	if playerScene.isInCave:
		playCaveAmbient(LocationLoaderS.currentPathway)
	else:
		playSettlementAmbient(LocationLoaderS.currentLocation)
