extends Resource

class_name Dialog

@export var title: String
@export_multiline var description: String
@export var choices: Array[DialogChoice]
@export var canExit: bool = false
