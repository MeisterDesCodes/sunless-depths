extends CharacterBody2D

@onready var navigationHandler = $"NavigationAgent2D"
@onready var animations = $"AnimationPlayer"
@onready var attackCollision = $"DamageRadius/CollisionShape2D"
@onready var hurtParticles = $"CPUParticles2D"


var seesPlayer = false
var player = null

var maxHealth: float = 2000
var health: float = maxHealth
var knockbackStrength = 250
var knockback: Vector2 = Vector2.ZERO
var isKnockback: bool = false
var damage: float = 10
var attackState: bool = false
var moveSpeed: float = 100

func _ready():
	hurtParticles.visible = false
				
				
func _physics_process(delta):
	
	if seesPlayer:
		look_at(player.global_position)
	
	if !isKnockback:
		var direction = navigationHandler.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction * moveSpeed
		
	move_and_slide()
	
	
func _on_timer_timeout():
	if player != null && seesPlayer:
		navigationHandler.target_position = player.global_position
	
func _on_detection_radius_body_entered(body):
	seesPlayer = true
	player = body


func _on_detection_radius_body_exited(body):
	seesPlayer = false
	player = null


func _on_hitbox_body_entered(body):
	if !body.hitEntities.has(self):
		applyDamage(body)


func applyDamage(body):
		body.hitEntities.append(self)
		health -= body.damage
		if animations.is_playing():
			animations.stop()
		animations.play("damage-received")
		if health < maxHealth / 2:
			hurtParticles.visible = true
			hurtParticles.amount = (maxHealth / 2 - health) / maxHealth / 2 * 200
		if health <= 0:
			queue_free()
		toggleKnockback(body)
		toggleAwareness()
	
func toggleAwareness():
	$"DetectionRadius/CollisionShape2D".shape.radius = 300
	$"Awareness".start()
	
	
func toggleKnockback(body):
	isKnockback = true
	var knockback_vector = global_position.direction_to(body.global_position) * -1 * body.knockback
	velocity = knockback_vector
	await get_tree().create_timer(0.2).timeout
	isKnockback = false
	
	
func attack(body):
	attackState = true
	await get_tree().create_timer(0.5).timeout
	attackState = false

func isEnemy():
	pass


func _on_awareness_timeout():
	$"DetectionRadius/CollisionShape2D".shape.radius = 120
