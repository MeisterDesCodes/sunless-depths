extends CharacterBody2D


signal onDeath

@export var entityResource: Entity

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var game: Node2D = get_tree().get_root().get_node("GameController/Game")
@onready var navigationHandler = get_node("NavigationAgent2D")
@onready var animations = get_node("AnimationPlayer")
@onready var particleComponent = get_node("ParticleComponent")
@onready var hitbox = get_node("Hitbox")
@onready var resourceSpawner = get_node("ResourceSpawner")
@onready var stateMachine = get_node("StateMachine")
@onready var visionRange = get_node("DetectionRadius/CollisionShape2D")
@onready var collision = get_node("CollisionShape2D")
@onready var immunityFramesTimer = get_node("ImmunityFrames")
@onready var chaseAfterTimer = get_node("ChaseAfterTimer")
@onready var awarenessTimer = get_node("AwarenessTimer")
@onready var damageReceiver = get_node("DamageReceiver")
@onready var statusEffectComponent = get_node("StatusEffectComponent")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var soundComponent: Node2D = get_node("SoundComponent")
@onready var vision: Node2D = get_node("Vision")

var awarenessEffect = preload("res://entities/resources/status-effects/awareness-combat.tres")

var maxHealth: float
var health: float
var knockbackStrength: float
var damage: float
var moveSpeed: float

var isKnockback: bool = false
var knockbackVector: Vector2 = Vector2.ZERO
var immunityFramesActive: bool = false

var baseVisionRange: float
var visionRangeBaseModifier: float = 75
var visionRangeSpeedModifier: float = 0.25
var visionRangeAttackedModifier: float = 3
var visionRangeModifier: float = 1

var canDash: bool = true
var isDashing: bool = false
var canDealContactDamage: bool = false
var playerSpotted: bool = false

var canLaunchProjectile = true

var isAttacking: bool = true
var currentAttack: EnemyAttack

var isDying: bool = false
var currentThreshold: float = 0.25
var dissolveSpeed: float = 0.5


var attackCounter: int = 1

var damageModifier: float = 1
var meleeDamageModifier: float = 1
var rangedDamageModifier: float = 1
var damageTakenModifier: float = 1
var effectStrengthModifier: float = 1
var movementSpeedModifier: float = 1
var knockbackModifier: float = 1
var projectileSpeedModifier: float = 1
var projectileSpreadModifier: float = 1
var effectDurationRandomModifier: float = 1
var effectTakenStrengthModifier: float = 1
var effectTakenDurationModifier: float = 1
var dashingDamageModifier: float = 1

var rangedDamageAfterMeleeAttack: float = 0
var meleeDamageAfterRangedAttack: float = 0
var thirdAttackDamage: float = 0
var sightRadiusEntryEffect: float = 0
var critHealChance: float = 0
var critChance: float = 0

var damageRangeMin: float = 0.75
var damageRangeMax: float = 1.25


func _ready():
	maxHealth = entityResource.maxHealth
	health = entityResource.maxHealth
	moveSpeed = entityResource.moveSpeed
	sprite.texture = entityResource.texture
	
	var meleeAttacks = entityResource.attacks.filter(func(attack): return attack is EnemyMeleeAttack)
	if !meleeAttacks.is_empty():
		currentAttack = meleeAttacks.pick_random()
	
	updateVisionRange()


func _physics_process(delta):
	if !playerScene.canAct():
		return
	
	if isDying:
		currentThreshold += dissolveSpeed * delta
		sprite.material.set_shader_parameter("dissolve_threshold", currentThreshold)
		if currentThreshold >= 1.5:
			resourceSpawner.spawnResources(entityResource.drops, Enums.resourceSpawnType.DROP, global_position, Vector2.DOWN, UtilsS.resourceDropSpeed * 0.5)
			queue_free()
		return
	
	if isKnockback:
		velocity += knockbackVector
	
	move_and_slide()
	
	if stateMachine.getState(Enums.enemyStates.LAUNCH_PROJECTILE) && canLaunchProjectile && playerSpotted:
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.LAUNCH_PROJECTILE))

	if stateMachine.getState(Enums.enemyStates.DASH) && canDash && playerSpotted \
		&& global_position.distance_to(playerScene.global_position) <= (50 + moveSpeed / 2) * movementSpeedModifier:
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.DASH))
	
	for raycast in vision.get_children():
		if raycast.is_colliding():
			if raycast.get_collider() && raycast.get_collider().has_method("isPlayer"):
				toggleAwareness()
				if !playerSpotted:
					changeToAggressiveStage()



func getDistanceThreshold(distance: float):
	return distance + entityResource.moveSpeed * 0.5


func moveInDirection(direction: Vector2, speed: float):
	direction = direction.normalized()
	velocity = lerp(velocity, direction * speed * movementSpeedModifier, 0.1)


func moveToPath(speed: float, lookInDirection: bool):
	var nextPoint = navigationHandler.get_next_path_position()
	if nextPoint.distance_to(global_position) > 10:
		var direction = nextPoint - global_position
		moveInDirection(direction, speed)
		if !lookInDirection:
			direction *= -1
		rotation = lerp_angle(rotation, direction.normalized().angle(), 0.1)  
	else:
		velocity = Vector2.ZERO


func changeToLastState():
	#TODO
	changeToAggressiveStage()
	#stateMachine.onChange(stateMachine.currentState, stateMachine.lastState)


func changeToAggressiveStage():
	playerSpotted = true
	if stateMachine.getState(Enums.enemyStates.CHASE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.CHASE))
	if stateMachine.getState(Enums.enemyStates.KEEP_DISTANCE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.KEEP_DISTANCE))


func spotPlayer():
	toggleAwareness()
	changeToAggressiveStage()
	chaseAfterTimer.stop()


func _on_detection_radius_body_entered(body):
	spotPlayer()


func _on_detection_radius_body_exited(body):
	chaseAfterTimer.start()


func entityKilled():
	if playerScene.attackDelayAfterKill != 0:
		UtilsS.applyStatusEffect(playerScene, playerScene, UtilsS.setupEffect(preload("res://entities/resources/status-effects/kill-attack-delay.tres"), \
			playerScene.attackDelayAfterKill))
	
	if playerScene.movementSpeedAfterKill != 0:
		UtilsS.applyStatusEffect(playerScene, playerScene, UtilsS.setupEffect(preload("res://entities/resources/status-effects/kill-movement-speed.tres"), \
			playerScene.movementSpeedAfterKill))
	
	if playerScene.staminaGainAfterKill != 0:
		UtilsS.applyStatusEffect(playerScene, playerScene, UtilsS.setupEffect(preload("res://entities/resources/status-effects/kill-stamina-gain.tres"), \
			playerScene.staminaGainAfterKill))
	
	var shaderMaterial = preload("res://assets/UI/shaders/dissolve-material-entities.tres").duplicate()
	sprite.material = shaderMaterial

	stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.DEATH))
	isDying = true
	onDeath.emit(self)
	particleComponent.activateDeathParticles()
	particleComponent.activateDesintegrateParticles()


func toggleAwareness():
	for enemy in game.enemies.get_children():
		if enemy.global_position.distance_to(global_position) <= 300:
			UtilsS.applyStatusEffect(enemy, enemy, awarenessEffect)


func updateVisionRange():
	baseVisionRange = (visionRangeBaseModifier + entityResource.moveSpeed * visionRangeSpeedModifier) * visionRangeModifier
	visionRange.shape.radius = baseVisionRange


func isEnemy():
	pass


func _on_immunity_frames_timeout():
	immunityFramesActive = false


func _on_chase_after_timer_timeout():
	if stateMachine.getState(Enums.enemyStates.IDLE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.IDLE))
	playerSpotted = false
