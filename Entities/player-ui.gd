extends CharacterBody2D

signal updateHud
signal healthModified

@export var entityResource: Entity

@export var inventory: Inventory
@export var equippedWeapons: Array[Weapon]  = [null, null, null]

@onready var animations = $"AnimationPlayer"
@onready var hitboxCollision = $"RotationPoint/Hitbox/CollisionShape2D"
@onready var hitbox = $"RotationPoint/Hitbox"
@onready var hudUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/HudUI")
@onready var weaponInstance = get_node("RotationPoint/Weapons/Weapon")
@onready var immunityFramesTimer = get_node("ImmunityFrames")
@onready var damageReceiver = get_node("DamageReceiver")
@onready var statusEffectComponent = get_node("StatusEffectComponent")
@onready var lightSource = get_node("RotationPoint/LightSource")

var fistWeapon = preload("res://weapons/resources/fists.tres")

var isAttacking: bool = false
var attackOnCooldown: bool = false

var health: float
var healthRegeneration = 0.01
var level: int

var immunityFramesActive: bool = false
var isKnockback: bool = false
var knockbackVector: Vector2 = Vector2.ZERO
var isSprinting: bool = false
var isDashing: bool = false
var canDash: bool = true
var isInDialog: bool = false

var currentSupplyDrain: float
var currentOxygenDrain: float
var currentStaminaDrain: float
var currentStaminaRestore: float
var dashStaminaCost: float = 20


func _ready():
	$"RotationPoint/Image".texture = entityResource.texture
	updateActiveWeapon()
	updateStats()
	inventory.updateInventory()
	var sizeIncrease = 1 / UtilsS.getScalingValue(entityResource.perception * 0.5)
	lightSource.scale = Vector2(sizeIncrease, sizeIncrease)


func updateStats():
	health = entityResource.maxHealth
	currentStaminaRestore = entityResource.staminaRestore


func _physics_process(_delta):
	if isInDialog:
		return
	
	if !isKnockback && !isDashing:
		var direction = getDirection()
		var currentMoveSpeed = entityResource.moveSpeed
		if (direction.x != 0 && direction.y != 0):
			currentMoveSpeed /= pow(2, 0.5)
		
		if isSprinting && !isAttacking:
			currentMoveSpeed *= 1.35
		
		if isAttacking:
			currentMoveSpeed *= 0.5
		
		currentMoveSpeed *= 1 / UtilsS.getScalingValue(entityResource.agility * 0.25)
		velocity = lerp(velocity, direction * currentMoveSpeed, 0.15)
	
	if isKnockback:
		velocity += knockbackVector
	
	move_and_slide()


func getDirection():
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))


func updateActiveWeapon():
	if equippedWeapons[0]:
		weaponInstance.setup(self, equippedWeapons[0])
	else:
		weaponInstance.setup(self, fistWeapon)


func switchToNextWeapon(modifier: int):
	if !equippedWeapons.is_empty():
		var nextWeapon: Weapon
		var currentWeapon: Weapon
		
		if modifier > 0:
			currentWeapon = equippedWeapons[0]
			equippedWeapons.remove_at(0)
			equippedWeapons.push_back(currentWeapon)
		else:
			nextWeapon = equippedWeapons[equippedWeapons.size() - 1]
			equippedWeapons.remove_at(equippedWeapons.size() - 1)
			equippedWeapons.push_front(nextWeapon)
		
		hudUI.setupWeaponTextures()


func attack():
	if !attackOnCooldown:
		attackOnCooldown = true
		$"AttackDelay".wait_time = weaponInstance.weapon.attackDelay * UtilsS.getScalingValue(entityResource.agility * 0.35)
		$"AttackDelay".start()
		weaponInstance.attack(weaponInstance.global_position.direction_to(get_global_mouse_position()))
		updateHud.emit(0.5, weaponInstance.weapon.staminaCost, 1)


func processIncomingAttack(attack: Attack):
	if !immunityFramesActive:
		damageReceiver.receiveAttack(attack)
		healthModified.emit()


func entityKilled():
	pass


func isPlayer():
	pass


func _on_attack_delay_timeout():
	attackOnCooldown = false


func _on_immunity_frames_timeout():
	immunityFramesActive = false


func _on_stamina_restore_timeout():
	currentStaminaRestore = entityResource.staminaRestore


func _on_dash_timer_timeout():
	canDash = true
	hudUI.onDashCooldown()
