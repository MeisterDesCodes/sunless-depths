extends CharacterBody2D

@onready var navigationHandler = $"NavigationAgent2D"
@onready var animations = $"AnimationPlayer"
@onready var attackCollision = $"DamageRadius/CollisionShape2D"
@onready var bloodParticles = $"BloodParticles"
@onready var hitParticles = $"HitParticles"
@onready var hitbox = $"Hitbox"
@onready var resourceSpawner = $"ResourceSpawner"

var seesPlayer = false
var player = null

@export var enemy: Enemy

var maxHealth: float
var health: float
var knockbackStrength: float
var damage: float
var moveSpeed: float

var dropSpeed: float = 100

var isKnockback: bool = false
var knockback: Vector2 = Vector2.ZERO
var attackState: bool = false
var immunityFramesActive: bool = false


func update():
	maxHealth = enemy.maxHealth
	health = enemy.maxHealth
	knockbackStrength = enemy.knockbackStrength
	damage = enemy.damage
	moveSpeed = enemy.moveSpeed
	$"Sprite2D".texture = enemy.texture


func _ready():
	bloodParticles.visible = false
	update()


func _physics_process(delta):
	
	if seesPlayer:
		look_at(player.global_position)
	
	if !isKnockback:
		var direction = navigationHandler.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = lerp(velocity, direction * moveSpeed, 0.15)
		
	move_and_slide()
	
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		processIncomingAttack(body)
	
	
	
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
	processIncomingAttack(body)


func processIncomingAttack(body):
	if !immunityFramesActive && !body.hitEntities.has(self):
		immunityFramesActive = true
		body.hitEntities.append(self)
		$"ImmunityFrames".start()
		
		if body.has_method("isWeapon"):
			health -= body.weapon.damage
		else:
			health -= body.damage
		
		if animations.is_playing():
			animations.stop()
		animations.play("damage-received")
		hitParticles.restart()
		hitParticles.direction = global_position.direction_to(body.global_position).rotated(-rotation) * -1
		if health < maxHealth / 2:
			bloodParticles.visible = true
			bloodParticles.amount = (maxHealth / 2 - health) / maxHealth / 2 * 200
		if health <= 0:
			entityKilled()

		toggleKnockback(body)
		toggleAwareness()


func entityKilled():
	for i in enemy.drops.size():
		if enemy.drops[i].dropChance > randf():
			resourceSpawner.spawnResources(enemy.drops[i].resource, enemy.drops[i].amount,
				Enums.resourceSpawnType.DROP, global_position, Vector2.DOWN, dropSpeed)
		
	queue_free()


func toggleAwareness():
	$"DetectionRadius/CollisionShape2D".shape.radius = 300
	$"AwarenessTimer".start()
	
	
func toggleKnockback(body):
	isKnockback = true
	
	var knockback: float = 0
	if body.has_method("isWeapon"):
		knockback = body.weapon.knockback * -1
	else:
		knockback -= body.knockback

	var knockback_vector = global_position.direction_to(body.global_position) * knockback
	velocity = lerp(velocity, knockback_vector, 0.75)
	await get_tree().create_timer(0.2).timeout
	isKnockback = false


func isEnemy():
	pass


func _on_awareness_timeout():
	$"DetectionRadius/CollisionShape2D".shape.radius = 120


func _on_immunity_frames_timeout():
	immunityFramesActive = false
