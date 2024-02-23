extends StaticBody2D


var damage = 20
var knockback = 50
var speed = 500

var hitEntities: Array

var direction: Vector2 = Vector2.ZERO


func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	
	
func _physics_process(delta):
	position += direction * speed * delta
	
	
func _on_area_2d_body_entered(body):
	if !body.has_method("isPlayer"):
		queue_free()






