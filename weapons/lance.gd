extends StaticBody2D

@onready var animations = $"AnimationPlayer"
@onready var collision = $"CollisionShape2D"

var weapon: Weapon = Weapon.new() 

var hitEntities: Array

func update():
	$"Sprite2D".texture = weapon.texture

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
