extends CharacterBody2D

signal updateHud
signal healthModified

@export var moveSpeed: float
@export var inventory: Inventory
@export var availableWeapons: Array[Weapon]

@export var supplyDrainBase: float = 0.75
@export var oxygenDrainBase: float = 0.5
@export var staminaDrainBase: float = 0
@export var staminaRestoreBase: float = 15

@onready var weapons: Array
@onready var animations = $"AnimationPlayer"
@onready var hitboxCollision = $"RotationPoint/Hitbox/CollisionShape2D"
@onready var hitbox = $"RotationPoint/Hitbox"
@onready var HudUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/HudUI")

var attackState: bool = false
var attackOnCooldown: bool = false

var maxHealth: float = 25
var health: float = maxHealth
var healthRegeneration = 0.01

var immunityFramesActive: bool = false
var isKnockback: bool = false
var isSprinting: bool = false
var isDashing: bool = false
var canDash: bool = true
var isInDialog: bool = false

var lanceScene = preload("res://weapons/lance.tscn")
var crossbowScene = preload("res://weapons/crossbow.tscn")
var currentWeaponScene: StaticBody2D

var supplyDrain: float = supplyDrainBase
var oxygenDrain: float = oxygenDrainBase
var staminaDrain: float = staminaDrainBase
var staminaRestore: float = staminaRestoreBase
var dashStaminaCost: float = 20


func _ready():
	for weapon in availableWeapons:
		var weaponInstance: StaticBody2D
		match weapon.type:
			Enums.weaponTypes.LANCE:
				weaponInstance = lanceScene.instantiate()
				weaponInstance.rotation = deg_to_rad(90)
				weaponInstance.position += Vector2(15, 10)
			Enums.weaponTypes.CROSSBOW:
				weaponInstance = crossbowScene.instantiate()
				weaponInstance.rotation = deg_to_rad(60)
				weaponInstance.position += Vector2(15, 15)
		weaponInstance.weapon = weapon
		weaponInstance.update()
		$"RotationPoint/Weapons".add_child(weaponInstance)
			
	weapons = $"RotationPoint/Weapons".get_children()
	if weapons.size() > 0:
		currentWeaponScene = weapons[1]
		updateWeapons()


func _process(delta):
	if isInDialog:
		return
	
	if Input.is_action_just_pressed("dash"):
		if (canDash && !isKnockback && HudUI.stamina.value > dashStaminaCost):
			canDash = false
			isDashing = true
			HudUI.onDash()
			updateHud.emit(2, dashStaminaCost, 0.5)
			var dash_vector = global_position.direction_to(get_global_mouse_position()) * 400
			velocity = lerp(velocity, dash_vector, 0.5)
			$"DashTimer".start()
			await get_tree().create_timer(0.3).timeout
			isDashing = false
	
	if Input.is_action_just_pressed("interact"):
		pass
	
	if Input.is_action_just_pressed("switch"):
		switchToNextWeapon()
	
	if Input.get_action_strength("attack"):
		if HudUI.stamina.value >= currentWeaponScene.weapon.staminaCost:
			attack()
	
	if Input.get_action_strength("sprint") && HudUI.stamina.value > 0:
		isSprinting = true
		HudUI.onSprint()
		supplyDrain = supplyDrainBase + 1.25
		staminaDrain = 10
		staminaRestore = 0
		$"StaminaRestore".start()
	else:
		isSprinting = false
		HudUI.onWalk()
		supplyDrain = supplyDrainBase
		staminaDrain = staminaDrainBase


func _physics_process(_delta):
	if isInDialog:
		return
	
	if !isKnockback && !isDashing:
		var direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		var currentMoveSpeed = moveSpeed
		if (direction.x != 0 && direction.y != 0):
			currentMoveSpeed = moveSpeed / pow(2, 0.5)
		else:
			currentMoveSpeed = moveSpeed
		
		if isSprinting:
			currentMoveSpeed *= 1.35
		
		velocity = lerp(velocity, direction * currentMoveSpeed, 0.15)
	
	move_and_slide()

	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		processIncomingAttack(body)


func updateWeapons():
	for weapon in weapons:
		if weapon != currentWeaponScene:
			weapon.visible = false
		else:
			weapon.visible = true


func switchToNextWeapon():
	var index = weapons.find(currentWeaponScene)
	if index >= weapons.size() - 1:
		currentWeaponScene = weapons[0]
	else:
		currentWeaponScene = weapons[index + 1]
	
	attackOnCooldown = false
	updateWeapons()


func attack():
	if !attackOnCooldown:
		attackOnCooldown = true
		$"AttackDelay".wait_time = currentWeaponScene.weapon.attackDelay
		$"AttackDelay".start()
		currentWeaponScene.attack(currentWeaponScene.global_position, 
			currentWeaponScene.global_position.direction_to(get_global_mouse_position()))
		attackState = true
		updateHud.emit(2, currentWeaponScene.weapon.staminaCost, 0.5)
		await currentWeaponScene.animations.animation_finished
		attackState = false
	

func _on_hitbox_body_entered(body):
	processIncomingAttack(body)
	

func processIncomingAttack(body):
	var enemy = body.get_parent()
	if !immunityFramesActive:
		immunityFramesActive = true
		$"ImmunityFrames".start()
		health -= enemy.damage
		if health <= 0:
			pass
			
		if animations.is_playing():
			animations.stop()
		animations.play("damage-received")
		
		isKnockback = true
		var knockback_vector = global_position.direction_to(enemy.global_position) * -1 * enemy.knockbackStrength
		velocity = lerp(velocity, knockback_vector, 0.75)
		await get_tree().create_timer(0.2).timeout
		isKnockback = false
		
		healthModified.emit()


func isPlayer():
	pass


func _on_attack_delay_timeout():
	attackOnCooldown = false


func _on_immunity_frames_timeout():
	immunityFramesActive = false


func _on_stamina_restore_timeout():
	staminaRestore = staminaRestoreBase


func _on_dash_timer_timeout():
	canDash = true
	HudUI.onDashCooldown()
