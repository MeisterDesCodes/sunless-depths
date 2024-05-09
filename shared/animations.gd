extends Node


class_name Animations


func fadeInHeight(element, duration: float):
	element.scale.y = 0
	get_tree().create_tween().tween_property(element, "scale", Vector2(element.scale.x, 1), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fadeOutHeight(element, duration: float):
	get_tree().create_tween().tween_property(element, "scale", Vector2(element.scale.x, 0), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func setSize(element, size: float, duration: float):
	get_tree().create_tween().tween_property(element, "scale", Vector2(size, size), duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
