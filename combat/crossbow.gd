extends StaticBody2D

@onready var animations = $"AnimationPlayer"

var arrow = preload("res://combat/arrow.tscn")

var hitEntities: Array

var attackDelay = 0.2
var spread = 10

func attack(spawnPosition, attackDirection):
	if animations.is_playing():
		animations.stop()
	animations.play("attack")
	var test = arrow.instantiate()
	test.position = spawnPosition
	var spreadVector = randf_range(-spread / 2, spread / 2)
	test.direction = attackDirection.rotated(deg_to_rad(spreadVector))
	add_child(test)
