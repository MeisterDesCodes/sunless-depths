extends Resource


class_name DialogChoice

@export var title: String
@export_multiline var description: String
@export var statCheck: StatCheck
@export var requiredResources: Array[ChoiceResource]
@export var forbiddenResources: Array[ChoiceResource]

@export_subgroup("Sucess")
@export var addedResourcesS: Array[ChoiceResource]
@export var removedResourcesS: Array[ChoiceResource]
@export var nextDialogS: Dialog
@export var moveBackwardsS: int = -1

@export_subgroup("Failure")
@export var addedResourcesF: Array[ChoiceResource]
@export var removedResourcesF: Array[ChoiceResource]
@export var nextDialogF: Dialog
@export var moveBackwardsF: int = -1

@export_subgroup("Other")
@export var oneTimeUse: bool = false
@export var function: String
