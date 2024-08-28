extends Control


@onready var icon: TextureRect = get_node("PanelContainer/TextureRect")
@onready var damageAmount: Label = get_node("PanelContainer/DamageAmount")

var damageIndicator = preload("res://assets/UI/icons/entities/player/stats/Damage.png")

var angle: float = 30


func setup(spawnPosition: Vector2, damage: float, isDamage: bool, statusEffect):
	global_position = spawnPosition
	if damage < 1:
		damageAmount.text = "< 1"
	else:
		damageAmount.text = str(round(damage))
	angle = deg_to_rad(randf_range(-angle, angle))
	if statusEffect:
		icon.texture = load("res://assets/UI/icons/entities/status-effects/" + UtilsS.getEnumValue(Enums.statusEffectType, statusEffect.effectType) + ".png")
	else:
		icon.texture = damageIndicator


func _process(delta):
	position += Vector2.UP.rotated(angle)


func _on_disappear_timer_timeout():
	queue_free()
