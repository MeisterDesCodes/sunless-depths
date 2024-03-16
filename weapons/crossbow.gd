extends StaticBody2D

@onready var animations = $"AnimationPlayer"

var arrow = preload("res://weapons/arrow.tscn")

var weapon: Weapon = Weapon.new()

var hitEntities: Array

func update():
	$"Sprite2D".texture = weapon.texture
	
func attack(spawnPosition, attackDirection):
	if animations.is_playing():
		animations.stop()
	animations.play("attack")
	var arrowInstance = arrow.instantiate()
	arrowInstance.position = spawnPosition
	var spreadVector = randf_range(-weapon.spread / 2, weapon.spread / 2)
	arrowInstance.direction = attackDirection.rotated(deg_to_rad(spreadVector))
	add_child(arrowInstance)

func isWeapon():
	pass
