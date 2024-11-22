extends PanelContainer


@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var statTexture: TextureRect = get_node("Stat")
@onready var chanceTexture: TextureRect = get_node("Chance")

var statIcons: Array[Texture] = [preload("res://assets/UI/icons/entities/player/stats/Ferocity.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perseverance.png"),
	preload("res://assets/UI/icons/entities/player/stats/Agility.png"),
	preload("res://assets/UI/icons/entities/player/stats/Perception.png")]
var choice: DialogChoice = null
var chance: float

func setup(_choice: DialogChoice):
	choice = _choice
	statTexture.texture = statIcons[choice.statCheck.stat]
	chance = UtilsS.getStatCheckChance(playerScene, choice.statCheck)
	if chance <= 0.25:
		chanceTexture.self_modulate = UtilsS.colorMissing
	if chance > 0.25 && chance <= 0.5:
		chanceTexture.self_modulate = UtilsS.colorPrimary
	if chance > 0.5 && chance <= 0.75:
		chanceTexture.self_modulate = UtilsS.colorLegendary
	if chance > 0.75:
		chanceTexture.self_modulate = UtilsS.colorUncommon


func _on_mouse_entered():
	var text: String = "Your " + UtilsS.getEnumValue(Enums.statType, choice.statCheck.stat) + \
		" gives you a " + str(chance * 100) + "% chance of success"
	UILoaderS.loadUITooltip(self, text)


func _on_mouse_exited():
	UILoaderS.closeUITooltip()
