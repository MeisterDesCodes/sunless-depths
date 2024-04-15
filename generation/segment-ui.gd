extends Node2D


@export var exits: Array[Dictionary] = [{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.TOP,
	"completed": false,
	"room": Node2D
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.RIGHT,
	"completed": false,
	"room": Node2D
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.DOWN,
	"completed": false,
	"room": Node2D
},
{
	"position": Vector2(0, 0),
	"direction": Enums.exitDirection.LEFT,
	"completed": false,
	"room": Node2D
}]
@export var type: Enums.segmentType
