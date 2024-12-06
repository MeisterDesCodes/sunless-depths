extends PanelContainer


@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var icon: TextureRect = get_node("Icon")
@onready var amountLabel: Label = get_node("Amount")

var resource: InventoryResource
var amount: int
var missing: bool = false
var tooMuch: bool = false
var requirementEnough: bool = false


func setup(_resource, _amount, _texture, showNumber: bool, isRequirement: bool, isNonRequirement: bool = false):
	resource = _resource
	amount = _amount
	icon.texture = _texture
	
	if showNumber && !(_resource is InventoryWeapon) && !(_resource is InventoryEquipment):
		amountLabel.text = str(_amount)
	
	if isRequirement:
		self_modulate = UtilsS.colorUncommon
		if _amount > playerScene.inventory.getResourceAmount(_resource) && !isNonRequirement:
			self_modulate = UtilsS.colorMissing
			missing = true
			
		if _amount <= playerScene.inventory.getResourceAmount(_resource) && isNonRequirement:
			self_modulate = UtilsS.colorMissing
			tooMuch = true
		
		if _amount > playerScene.inventory.getResourceAmount(_resource) && isNonRequirement:
			requirementEnough = true


func _on_mouse_entered():
	var text: String
	
	if missing:
		text = "You needed " + str(amount) + " " + UtilsS.pluralizeResource(resource, amount)
	if tooMuch:
		text = "You needed no " + UtilsS.pluralizeResource(resource, amount)
	if requirementEnough:
		text = "You unlocked this with having less than " + str(amount) + \
			" " + UtilsS.pluralizeResource(resource, amount)
	if !missing && !tooMuch && !requirementEnough:
		text = "You unlocked this with " + str(playerScene.inventory.getResourceAmount(resource)) + \
			" " + UtilsS.pluralizeResource(resource, amount)
	
	UILoaderS.loadUITooltip(self, text)


func _on_mouse_exited():
		UILoaderS.closeUITooltip()
