extends StaticBody2D


var damage = 150
var knockback = 50
var speed = 500

var hitEntities: Array

var direction: Vector2 = Vector2.ZERO

#var weapon = Weapon.new()

func _ready():
	look_at(position + direction)
	
	
func _physics_process(delta):
	position += direction * speed * delta
	
	
func _on_area_2d_body_entered(body):
	if !body.has_method("isPlayer"):
		queue_free()






