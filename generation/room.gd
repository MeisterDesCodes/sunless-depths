extends Node2D


@export var exits: Array[Dictionary] = [{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.TOP,
	"completed": false
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.RIGHT,
	"completed": false
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.DOWN,
	"completed": false
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.LEFT,
	"completed": false
}]
@export var type: Enums.segmentType
