extends PanelContainer


@onready var icon: TextureRect = get_node("Icon")
@onready var progressBar: TextureProgressBar = get_node("TextureProgressBar")

var effect: StatusEffect


func update(effect):
	get_tree().create_tween().tween_property(progressBar, "value", (effect.remainingDuration / effect.duration) * 100, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	if effect.remainingDuration <= 0:
		queue_free()


func setup(_effect: StatusEffect):
	effect = _effect
	progressBar.value = 100
	icon.texture = load("res://assets/UI/icons/entities/status-effects/" + UtilsS.getEnumValue(Enums.statusEffectType, effect.effectType) + ".png")


func _on_mouse_entered():
	UILoaderS.loadUIPopup(self, effect)


func _on_mouse_exited():
	UILoaderS.closeUIPopup()
