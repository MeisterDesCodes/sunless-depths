extends Node


@onready var allLocations = get_node("PanelContainer/Locations").get_children()
@onready var allPathways = get_node("PanelContainer/Pathways").get_children()


func _ready():
	for locationInstance in allLocations:
		if locationInstance.locationResource:
			if !isOuterRing(locationInstance.locationResource.location):
				locationInstance.ringLevel = Enums.locationRingLevel.NONE
			if isOuterRing(locationInstance.locationResource.location):
				locationInstance.ringLevel = Enums.locationRingLevel.OUTER
			if isVisited(locationInstance.locationResource.location):
				locationInstance.ringLevel = Enums.locationRingLevel.VISITED
			if isInnerRing(locationInstance.locationResource.location):
				locationInstance.ringLevel = Enums.locationRingLevel.INNER
			if isCurrent(locationInstance.locationResource.location):
				locationInstance.ringLevel = Enums.locationRingLevel.CURRENT
			
			locationInstance.updateLocation()
			
			var connectedLocations: Array[Enums.locations]
			for visitedLocation in LocationLoaderS.visitedLocations:
				connectedLocations.append_array(getSurroudingLocations(visitedLocation))
			
			for pathwayInstance in allPathways:
				if pathwayInstance.pathwayResource:
					if !(pathwayInstance.pathwayResource.locationFrom in connectedLocations) && !(pathwayInstance.pathwayResource.locationTo in connectedLocations):
						pathwayInstance.queue_free()


func isVisited(location: Enums.locations):
	return location in LocationLoaderS.visitedLocations


func isCurrent(location: Enums.locations):
	return location == LocationLoaderS.currentLocation.location


func isInnerRing(location: Enums.locations):
	return location in getSurroudingLocations(LocationLoaderS.currentLocation.location)


func isOuterRing(location: Enums.locations):
	var outerRing: Array[Enums.locations]
	var innerRing = getSurroudingLocations(LocationLoaderS.currentLocation.location)
	for innerLocation in innerRing:
		outerRing.append_array(getSurroudingLocations(innerLocation))
	return location in outerRing


func getSurroudingLocations(location: Enums.locations):
	var surroudingLocations: Array[Enums.locations]
	for pathwayInstance in allPathways:
		if pathwayInstance.pathwayResource:
			if pathwayInstance.pathwayResource.locationFrom == location:
				surroudingLocations.append(pathwayInstance.pathwayResource.locationTo)
			if pathwayInstance.pathwayResource.locationTo == location:
				surroudingLocations.append(pathwayInstance.pathwayResource.locationFrom)
	return surroudingLocations
