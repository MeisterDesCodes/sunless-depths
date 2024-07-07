extends CharacterBody2D

signal updateHud
signal healthModified

@export var entityResource: Entity

@export var inventory: Inventory

@onready var animations = $"AnimationPlayer"
@onready var hudUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/HudUI")
@onready var weaponInstance = get_node("RotationPoint/Weapons/Weapon")
@onready var immunityFramesTimer = get_node("ImmunityFrames")
@onready var damageReceiver = get_node("DamageReceiver")
@onready var statusEffectComponent = get_node("StatusEffectComponent")
@onready var lightSource = get_node("RotationPoint/LightSource")
@onready var camera = get_tree().get_root().get_node("Game/FollowCamera")

var fistWeapon = preload("res://weapons/resources/fists.tres")
var equippedWeapons: Array[InventoryWeapon]  = [fistWeapon, fistWeapon, fistWeapon]
var equippedGear: Array[InventoryEquipment]  = [null, null, null, null]

var isAttacking: bool = false
var attackOnCooldown: bool = false

var health: float
var healthRegeneration = 0.01
var level: int

var immunityFramesActive: bool = false
var isKnockback: bool = false
var knockbackVector: Vector2 = Vector2.ZERO
var currentMoveSpeed: float
var isWalking: bool = false
var isSprinting: bool = false
var isDashing: bool = false
var canDash: bool = true
var isInDialog: bool = false
var isInLoadingScreen: bool = false
var isDying: bool = false

var currentSupplyDrain: float
var currentOxygenDrain: float
var currentStaminaDrain: float
var currentStaminaRestore: float
var dashStaminaCost: float = 20

var baseZoom: float = 2.5
var currentZoom: int = 0
var maxZoom: int = 5

var atExit: bool = false
var atLocation: bool = true


func _ready():
	$"RotationPoint/Image".texture = entityResource.texture
	updateActiveWeapon()
	updateStats()
	inventory.updateResourceTypes()
	var sizeIncrease = 1 / UtilsS.getScalingValue(entityResource.perception * 0.5)
	lightSource.scale = Vector2(sizeIncrease, sizeIncrease)
	camera.zoom = Vector2(baseZoom, baseZoom)


func updateStats():
	health = entityResource.maxHealth
	currentStaminaRestore = entityResource.staminaRestore


func _physics_process(_delta):
	if !canAct():
		return
	
	if !isKnockback && !isDashing:
		var direction = getDirection()
		
		if direction != Vector2.ZERO:
			isWalking = true
		else:
			isWalking = false
		
		currentMoveSpeed = entityResource.moveSpeed
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
	weaponInstance.setup(self, equippedWeapons[0])


func switchToNextWeapon(modifier: int):
	var nextWeapon: InventoryWeapon
	var currentWeapon: InventoryWeapon
	
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
	if canAttack():
		attackOnCooldown = true
		$"AttackDelay".wait_time = weaponInstance.weapon.attackDelay * UtilsS.getScalingValue(entityResource.agility * 0.35)
		$"AttackDelay".start()
		weaponInstance.attack(Vector2.RIGHT.rotated(weaponInstance.get_parent().get_parent().rotation))
		updateHud.emit(0.5, 1, weaponInstance.weapon.staminaCost)
		hudUI.setupWeaponTextures()


func canAttack():
	return !attackOnCooldown && (weaponInstance.weapon is MeleeWeapon || weaponInstance.weapon.ammunition)


func processIncomingAttack(attack: Attack):
	if !immunityFramesActive:
		damageReceiver.receiveAttack(attack)
		healthModified.emit()


func zoom():
	currentZoom = (currentZoom + 1) % maxZoom
	var zoom: float = baseZoom - 0.2 * currentZoom
	get_tree().create_tween().tween_property(camera, "zoom", Vector2(zoom, zoom), 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


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

func canAct():
	return !isInDialog && !isInLoadingScreen





