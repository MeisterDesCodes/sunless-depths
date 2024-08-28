extends CharacterBody2D


signal onDeath

@export var entityResource: Entity

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var navigationHandler = get_node("NavigationAgent2D")
@onready var animations = get_node("AnimationPlayer")
@onready var particleComponent = get_node("ParticleComponent")
@onready var hitbox = get_node("Hitbox")
@onready var resourceSpawner = get_node("ResourceSpawner")
@onready var stateMachine = get_node("StateMachine")
@onready var visionRange = get_node("DetectionRadius/CollisionShape2D")
@onready var immunityFramesTimer = get_node("ImmunityFrames")
@onready var chaseAfterTimer = get_node("ChaseAfterTimer")
@onready var awarenessTimer = get_node("AwarenessTimer")
@onready var damageReceiver = get_node("DamageReceiver")
@onready var statusEffectComponent = get_node("StatusEffectComponent")
@onready var image: Sprite2D = get_node("Sprite2D")

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
var visionRangeSpeedModifier = 0.5
var visionRangeAttackedModifier = 2
var visionRangeModifier = 1

var canDash = true
var isDashing = false

var canLaunchProjectile = true

var isAttacking = true
var currentAttack: EnemyAttack

var isDying: bool = false


var attackCounter: int = 1

var meleeDamageModifier: float = 1
var rangedDamageModifier: float = 1
var effectStrengthModifier: float = 1
var movementSpeedModifier: float = 1
var knockbackModifier: float = 1
var projectileSpeedModifier: float = 1
var projectileSpreadModifier: float = 1
var effectDurationRandomModifier: float = 1
var effectTakenStrengthModifier: float = 1
var effectTakenDurationModifier: float = 1

var rangedDamageAfterMeleeAttack: float = 0
var meleeDamageAfterRangedAttack: float = 0
var thirdAttackDamage: float = 0
var sightRadiusEntryEffect: float = 0


func _ready():
	maxHealth = entityResource.maxHealth
	health = entityResource.maxHealth
	moveSpeed = entityResource.moveSpeed
	$"Sprite2D".texture = entityResource.texture
	currentAttack = entityResource.attacks[0]
	updateVisionRange()


func _physics_process(delta):
	if !playerScene.canAct():
		return
	
	if isKnockback:
		velocity += knockbackVector
	
	move_and_slide()
	
	if stateMachine.getState(Enums.enemyStates.LAUNCH_PROJECTILE) && canLaunchProjectile && stateMachine.currentState != stateMachine.getState(Enums.enemyStates.IDLE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.LAUNCH_PROJECTILE))

	if stateMachine.getState(Enums.enemyStates.DASH) && canDash && global_position.distance_to(playerScene.global_position) <= (100 + moveSpeed) * movementSpeedModifier:
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.DASH))


func getDistanceThreshold(distance: float):
	return distance + entityResource.moveSpeed * 0.5


func moveInDirection(direction: Vector2, speed: float):
	direction = direction.normalized()
	velocity = lerp(velocity, direction * speed * movementSpeedModifier, 0.15)


func moveToPath(speed: float):
	var nextPoint = navigationHandler.get_next_path_position()
	if nextPoint.distance_to(global_position) > 10:
		var direction = nextPoint - global_position
		moveInDirection(direction, speed)
		rotation = lerp_angle(rotation, global_position.direction_to(navigationHandler.get_next_path_position()).normalized().angle(), 0.05)
	else:
		velocity = Vector2.ZERO


func changeToLastState():
	stateMachine.onChange(stateMachine.currentState, stateMachine.lastState)


func changeToAggressiveStage():
	if stateMachine.getState(Enums.enemyStates.CHASE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.CHASE))
	if stateMachine.getState(Enums.enemyStates.KEEP_DISTANCE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.KEEP_DISTANCE))


func _on_detection_radius_body_entered(body):
	changeToAggressiveStage()
	chaseAfterTimer.stop()


func _on_detection_radius_body_exited(body):
	chaseAfterTimer.start()


func processIncomingAttack(attack: Attack):
	toggleAwareness()
	damageReceiver.receiveAttack(attack)


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
	
	isDying = true
	resourceSpawner.spawnResources(entityResource.drops, Enums.resourceSpawnType.DROP, global_position, Vector2.DOWN, UtilsS.resourceDropSpeed * 0.5)
	
	onDeath.emit(self)
	queue_free()



func toggleAwareness():
	UtilsS.applyStatusEffect(self, self, awarenessEffect)


func updateVisionRange():
	baseVisionRange = (150 + entityResource.moveSpeed * visionRangeSpeedModifier) * visionRangeModifier
	visionRange.shape.radius = baseVisionRange


func isEnemy():
	pass


func _on_immunity_frames_timeout():
	immunityFramesActive = false


func _on_chase_after_timer_timeout():
	if stateMachine.getState(Enums.enemyStates.IDLE):
		stateMachine.onChange(stateMachine.currentState, stateMachine.getState(Enums.enemyStates.IDLE))
