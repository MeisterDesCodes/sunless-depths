extends Resource


class_name LevelUpCard


@export var name: String
@export var description: String
@export var icon: Texture
@export var requirements: Array[LevelUpCard]
@export var type: Enums.cardType
@export var value: float
@export var value2: float
@export var stats: Array[CardResource]
@export var tier: int = 1
