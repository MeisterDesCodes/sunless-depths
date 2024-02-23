extends CharacterBody2D


@export var moveSpeed: float = 200
@export var inventory: Inventory

@onready var rubble: InventoryResource = preload("res://Inventory/resources/rubble.tres")
@onready var planks: InventoryResource = preload("res://Inventory/resources/planks.tres")
@onready var caveshroom: InventoryResource = preload("res://Inventory/resources/caveshroom.tres")
@onready var animations = $"AnimationPlayer"
@onready var weapons = $"RotationPoint/Weapons".get_children()
@onready var hitboxCollision = $"RotationPoint/Hitbox/CollisionShape2D"
@onready var hitbox = $"RotationPoint/Hitbox"


var attackState: bool = false
var attackOnCooldown: bool = false

var health: int = 1000
var isKnockback: bool = false
var immunityFramesActive: bool = false

var currentWeapon


func _ready():
	currentWeapon = weapons[0]
	updateWeapons()
			
			
func updateWeapons():
	for weapon in weapons:
		if weapon != currentWeapon:
			weapon.visible = false
		else:
			weapon.visible = true
	
	
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		inventory.addResource(rubble, 5)
		inventory.addResource(planks, 5)
		inventory.addResource(caveshroom, 5)
	
	if Input.is_action_just_pressed("switch"):
		switchToNextWeapon()
		
	if Input.get_action_strength("attack"):
		attack()
		
		
func _physics_process(_delta):
	
	if !isKnockback:
		var direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		var currentMoveSpeed = moveSpeed
		if (direction.x != 0 && direction.y != 0):
			currentMoveSpeed = moveSpeed * 0.7
		else:
			currentMoveSpeed = moveSpeed
		velocity = direction * currentMoveSpeed
	
	move_and_slide()

	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		processIncomingAttack(body)


func switchToNextWeapon():
	var index = weapons.find(currentWeapon)
	if index >= weapons.size() - 1:
		currentWeapon = weapons[0]
	else:
		currentWeapon = weapons[index + 1]
	updateWeapons()
	attackOnCooldown = false
	
	
func attack():
	if !attackOnCooldown:
		attackOnCooldown = true
		$"AttackDelay".wait_time = currentWeapon.attackDelay
		$"AttackDelay".start()
		currentWeapon.attack(currentWeapon.global_position, 
			currentWeapon.global_position.direction_to(get_global_mouse_position()))
		attackState = true
		await currentWeapon.animations.animation_finished
		attackState = false
	

func _on_hitbox_body_entered(body):
	processIncomingAttack(body)
	

func processIncomingAttack(body):
	var enemy = body.get_parent()
	enemy.attack(self)
	if !immunityFramesActive:
		immunityFramesActive = true
		$"ImmunityFrames".start()
		health -= enemy.damage
		if health <= 0:
			queue_free()
		if animations.is_playing():
			animations.stop()
		animations.play("damage-received")
		
		isKnockback = true
		var knockback_vector = global_position.direction_to(enemy.global_position) * -1 * enemy.knockbackStrength
		velocity = knockback_vector
		await get_tree().create_timer(0.2).timeout
		isKnockback = false
		
	
	
func isPlayer():
	pass


func _on_attack_delay_timeout():
	attackOnCooldown = false


func _on_immunity_frames_timeout():
	immunityFramesActive = false
