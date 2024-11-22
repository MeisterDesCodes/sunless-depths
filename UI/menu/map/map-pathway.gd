extends Resource


class_name MapPathway

@export var name: String
@export var description: String
@export var iterations: int
@export var tier: int
@export var locationFrom: Enums.locations
@export var locationTo: Enums.locations
@export var travelDirections: Array[Enums.exitDirection]
@export var attributes: Array[Enums.locationAttribute]
@export var caveVariation: Enums.caveVariations

var type = Enums.resourceType.MAP_PATHWAY
