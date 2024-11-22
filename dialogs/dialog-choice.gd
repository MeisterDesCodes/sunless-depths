extends Resource


class_name DialogChoice

@export var title: String
@export_multiline var description: String
@export var statCheck: StatCheck
@export var requiredResources: Array[ChoiceResource]

@export_subgroup("Sucess")
@export var addedResourcesS: Array[ChoiceResource]
@export var removedResourcesS: Array[ChoiceResource]
@export var nextDialogS: Dialog

@export_subgroup("Failure")
@export var addedResourcesF: Array[ChoiceResource]
@export var removedResourcesF: Array[ChoiceResource]
@export var nextDialogF: Dialog

@export_subgroup("Other")
@export var optionalMoveBackwards: int = -1
@export var oneTimeUse: bool = false
@export var function: String
