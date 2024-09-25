extends Node


class_name Animations


func fadeInHeight(element, duration: float):
	element.scale.y = 0
	get_tree().create_tween().tween_property(element, "scale", Vector2(element.scale.x, 1), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeOutHeight(element, duration: float):
	get_tree().create_tween().tween_property(element, "scale", Vector2(element.scale.x, 0), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func setSize(element, size: float, duration: float):
	get_tree().create_tween().tween_property(element, "scale", Vector2(size, size), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeInVisible(element, duration: float):
	get_tree().create_tween().tween_property(element, "modulate", Color(element.modulate.r, element.modulate.g, element.modulate.b, 1), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeOutVisible(element, duration: float):
	get_tree().create_tween().tween_property(element, "modulate", Color(element.modulate.r, element.modulate.g, element.modulate.b, 0), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func slideUp(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "position", Vector2(element.position.x, -amount), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func slideDown(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "position", Vector2(element.position.x, amount), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func changeColor(element, color: Color, duration: float):
	get_tree().create_tween().tween_property(element, "self_modulate", Color(color), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func scroll(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "scroll_vertical", amount, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func fadeSound(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "volume_db", amount, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)









