extends HBoxContainer


@onready var icon: TextureRect = get_node("PanelContainer/TextureRect")
@onready var stat: Label = get_node("PanelContainer2/Stat")
@onready var description: Label = get_node("PanelContainer3/Description")


func setup(_texture, _stat, _description):
	icon.texture = _texture
	stat.text = _stat
	description.text = _description
