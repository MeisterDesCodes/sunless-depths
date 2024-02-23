extends StaticBody2D

@onready var animations = $"AnimationPlayer"
@onready var collision = $"CollisionShape2D"

var damage = 35
var knockback = 100
var attackDelay = 0.75

var hitEntities: Array

func attack(spawnPosition, attackDirection):
	hitEntities = []
	if animations.is_playing():
		animations.stop()
	animations.play("attack")
	collision.disabled = false
	await animations.animation_finished
	collision.disabled = true
	
func isWeapon():
	pass
