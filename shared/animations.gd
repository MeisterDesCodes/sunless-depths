extends Node


class_name Animations


func fadeHeight(element, amount: float, duration: float):
	if amount > 0:
		element.scale.y = 0
	get_tree().create_tween().tween_property(element, "scale", Vector2(element.scale.x, amount), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeWidth(element, amount: float, duration: float):
	if amount > 0:
		element.scale.x = 0
	get_tree().create_tween().tween_property(element, "scale", Vector2(amount, element.scale.y), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func setSize(element, size: float, duration: float):
	get_tree().create_tween().tween_property(element, "scale", Vector2(size, size), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeVisible(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "modulate", Color(element.modulate.r, element.modulate.g, element.modulate.b, amount), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeSlide(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "position", Vector2(element.position.x, amount), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func changeColor(element, color: Color, duration: float):
	get_tree().create_tween().tween_property(element, "self_modulate", Color(color), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func scroll(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "scroll_vertical", amount, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func fadeSound(element, amount: float, duration: float):
	get_tree().create_tween().tween_property(element, "volume_db", amount, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)









