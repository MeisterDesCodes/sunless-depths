extends Node


@onready var allLocations = get_node("AspectRatioContainer/NinePatchRect2/Locations").get_children()
@onready var allPathways = get_node("AspectRatioContainer/NinePatchRect2/Pathways").get_children()


func _ready():
	for location in allLocations:
		if !isOuterRing(location.location):
			location.modulate = UtilsS.colorTransparent
		if isOuterRing(location.location):
			location.modulate = UtilsS.colorBlack
		if isInnerRing(location.location):
			location.modulate = UtilsS.colorCommon
			location.canBeVisited = true
		if isVisited(location.location):
			location.modulate = UtilsS.colorPrimary
	
		var connectedLocations: Array[String]
		for visitedLocation in LocationLoaderS.visitedLocations:
			connectedLocations.append_array(getSurroudingLocations(visitedLocation))
		
		for pathway in allPathways:
			if !(pathway.locationFrom in connectedLocations) && !(pathway.locationTo in connectedLocations):
				pathway.modulate = UtilsS.colorTransparent


func isVisited(location: String):
	return location in LocationLoaderS.visitedLocations


func isInnerRing(location: String):
	return location in getSurroudingLocations(LocationLoaderS.currentLocation)


func isOuterRing(location: String):
	var outerRing: Array[String]
	var innerRing = getSurroudingLocations(LocationLoaderS.currentLocation)
	for innerLocation in innerRing:
		outerRing.append_array(getSurroudingLocations(innerLocation))
	return location in outerRing


func getSurroudingLocations(location: String):
	var surroudingLocations: Array[String]
	for pathway in allPathways:
		if pathway.locationFrom == location:
			surroudingLocations.append(pathway.locationTo)
		if pathway.locationTo == location:
			surroudingLocations.append(pathway.locationFrom)
	return surroudingLocations
