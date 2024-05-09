extends Resource


class_name DialogChoice

@export var title: String
@export_multiline var description: String
@export var requiredResources: Array[ChoiceResource]
@export var addedResources: Array[ChoiceResource]
@export var removedResources: Array[ChoiceResource]
@export var nextDialog: Dialog
@export var optionalMoveBackwards: int = -1
@export var oneTimeUse: bool = false
@export var function: String
