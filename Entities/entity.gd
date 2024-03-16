extends Resource

class_name Enemy

@export var name: String
@export var texture: Texture2D
@export var maxHealth: float
@export var knockbackStrength: float
@export var damage: float
@export var moveSpeed: float
@export var drops: Array[DropResource]
