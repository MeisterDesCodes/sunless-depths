extends Resource


class_name MapPathway

@export var name: String
@export var description: String
@export var iterations: int
@export var locationFrom: Enums.locations
@export var locationTo: Enums.locations
@export var travelDirections: Array[Enums.exitDirection]
@export var tier: int

var type = Enums.resourceType.MAP_PATHWAY
