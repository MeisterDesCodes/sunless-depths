extends CharacterBody2D

signal updateHud
signal healthModified

@export var entityResource: Entity

@export var inventory: Inventory

@onready var animations =  get_node("AnimationPlayer")
@onready var hudUI = get_tree().get_root().get_node("Game/CanvasLayer/UIControl/HudUI")
@onready var weaponInstance = get_node("RotationPoint/Weapons/Weapon")
@onready var immunityFramesTimer = get_node("ImmunityFrames")
@onready var damageReceiver = get_node("DamageReceiver")
@onready var statusEffectComponent = get_node("StatusEffectComponent")
@onready var lightSource = get_node("RotationPoint/LightSource")
@onready var camera = get_tree().get_root().get_node("Game/FollowCamera")

@onready var staminaRestoreTimer: Timer = get_node("StaminaRestore")
@onready var staminaRestoreExhaustTimer: Timer = get_node("StaminaExhaustRestore")
@onready var dashTimer: Timer = get_node("DashTimer")
@onready var consumeTimer: Timer = get_node("ConsumeTimer")

var fistWeapon = preload("res://weapons/resources/fists.tres")
var equippedWeapons: Array[InventoryWeapon]  = [fistWeapon, fistWeapon, fistWeapon]
var equippedGear: Array[InventoryEquipment]  = [null, null, null, null, null, null, null]

var isAttacking: bool = false
var attackOnCooldown: bool = false

var maxHealth: float
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
var exhaustionPenalty: float = 75

var selectedCards: Array[LevelUpCard]

var meleeDamageModifier: float = 1
var rangedDamageModifier: float = 1
var attackDelayModifier: float = 1
var healthModifier: float = 1
var movementSpeedModifier: float = 1
var sightRadiusModifier: float = 1
var lootModifier: float = 1
var effectStrengthModifier: float = 3
var staminaCostModifier: float = 1
var criticalDamageModifier: float = 1

var baseZoom: float = 0.5
var currentZoom: int = 0
var maxZoom: int = 5

var atExit: bool = false
var isInCave: bool = false


func _ready():
	$"RotationPoint/Image".texture = entityResource.texture
	initializePlayer()
	updateActiveWeapon()
	updateWepaonTypes()
	setupLightSource()
	inventory.updateResourceTypes()
	camera.zoom = Vector2(baseZoom, baseZoom)


func initializePlayer():
	currentStaminaRestore = entityResource.staminaRestore
	equipInitialItem(preload("res://inventory-resource/resources/equipment/rusty-tank.tres"))
	equipInitialItem(preload("res://inventory-resource/resources/equipment/old-torch.tres"))
	updateMaxHealth()
	health = maxHealth


func updateMaxHealth():
	maxHealth = (entityResource.maxHealth + entityResource.perseverance) * 1 / UtilsS.getScalingValue(entityResource.perseverance * 2) * healthModifier
	if health > maxHealth:
		health = maxHealth


func equipInitialItem(equipment: InventoryEquipment):
	var slot = inventory.getResourceSlot(equipment)
	if slot:
		UtilsS.equipItem(self, slot.resource, slot.resource.equipmentType)


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
		
		currentMoveSpeed *= 1 / UtilsS.getScalingValue(entityResource.agility * 0.5) * movementSpeedModifier
		velocity = lerp(velocity, direction * currentMoveSpeed, 0.15)
	
	if isKnockback:
		velocity += knockbackVector
	
	move_and_slide()


func getDirection():
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))


func setupLightSource():
	var size = entityResource.lightRadius
	var sizeIncrease = 1 / UtilsS.getScalingValue(entityResource.perception * 0.5)
	lightSource.update(size * sizeIncrease)


func updateWeapons():
	updateActiveWeapon()
	updateWepaonTypes()
	hudUI.setupWeaponTextures()


func updateActiveWeapon():
	weaponInstance.setup(self, equippedWeapons[0])


func updateWepaonTypes():
	for weapon in equippedWeapons:
		UtilsS.updateResourceType(weapon)


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
	
	updateWeapons()


func useStamina(staminaCost):
	currentStaminaRestore = 0
	staminaRestoreTimer.stop()
	if hudUI.staminaBar.value - (staminaCost * staminaCostModifier) > 0:
		staminaRestoreTimer.start()
	else:
		if staminaRestoreExhaustTimer.time_left == 0:
			entityResource.moveSpeed -= exhaustionPenalty
		staminaRestoreExhaustTimer.start()


func sprint():
	isSprinting = true
	hudUI.onSprint()
	currentSupplyDrain = entityResource.supplyDrain * 1.25
	currentOxygenDrain = entityResource.supplyDrain * 1.5
	currentStaminaDrain = 10
	useStamina(1)


func walk():
	isSprinting = false
	hudUI.onWalk()
	currentSupplyDrain = entityResource.supplyDrain
	currentOxygenDrain = entityResource.oxygenDrain
	currentStaminaDrain = entityResource.staminaDrain


func dash():
	canDash = false
	isDashing = true
	hudUI.onDash()
	updateHud.emit(1, 2, dashStaminaCost)
	var direction: Vector2 = getDirection()
	if direction == Vector2.ZERO:
		direction = global_position.direction_to(get_global_mouse_position())
	var speed: float = 150 + entityResource.moveSpeed * 1.5
	velocity = lerp(velocity, direction * speed, 0.5)
	useStamina(dashStaminaCost)
	
	dashTimer.start()
	await get_tree().create_timer(0.3).timeout
	isDashing = false


func attack():
	if canAttack():
		attackOnCooldown = true
		$"AttackDelay".wait_time = weaponInstance.weapon.attackDelay * UtilsS.getScalingValue(entityResource.agility * 0.35) * attackDelayModifier
		$"AttackDelay".start()
		weaponInstance.attack(Vector2.RIGHT.rotated(weaponInstance.get_parent().get_parent().rotation))
		updateHud.emit(0.5, 1, weaponInstance.weapon.staminaCost)
		updateWeapons()
		useStamina(weaponInstance.weapon.staminaCost)


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


func reduceConsumableCooldowns():
	for resourceSlot in inventory.resourceSlots:
		if resourceSlot.resource is InventoryConsumable && resourceSlot.resource.isOnCooldown:
			resourceSlot.resource.remainingCooldown -= consumeTimer.wait_time
			if resourceSlot.resource.remainingCooldown <= 0:
				resourceSlot.resource.isOnCooldown = false


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


func _on_stamina_exhaust_restore_timeout():
	currentStaminaRestore = entityResource.staminaRestore
	entityResource.moveSpeed += exhaustionPenalty


func _on_dash_timer_timeout():
	canDash = true
	hudUI.onDashCooldown()


func canAct():
	return !isInDialog && !isInLoadingScreen


func _on_consume_timer_timeout():
	reduceConsumableCooldowns()
