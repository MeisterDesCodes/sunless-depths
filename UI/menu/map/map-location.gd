extends Resource


class_name MapLocation

@export var name: String
@export_multiline var description: String
@export var tier: int
@export var locationType: Enums.locationType
@export var attributes: Array[Enums.locationAttribute]
@export var location: Enums.locations
@export var ambientMusic: Array[AudioStreamMP3]

var type = Enums.resourceType.MAP_LOCATION
