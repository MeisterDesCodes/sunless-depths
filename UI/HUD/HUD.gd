extends Control

@onready var player = get_tree().current_scene.get_node("Entities/Player")
@onready var supplies = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer".get_child(0)
@onready var oxygen = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer".get_child(0)
@onready var stamina = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer3/VBoxContainer".get_child(0)
@onready var suppliesLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer".get_child(1)
@onready var oxygenLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer".get_child(1)
@onready var staminaLabel = $"NinePatchRect/HBoxContainer/VBoxContainer/HBoxContainer3/VBoxContainer".get_child(1)
@onready var health = $"NinePatchRect/HBoxContainer/VBoxContainer2/Health"

@onready var allResources = preload("res://items/resources/all-resources.tres")

var suppliesBeingRestocked = false


func _ready():
	player.updateHud.connect(updateHud)
	player.healthModified.connect(healthModified)
	health.value = 100
	supplies.value = 100
	oxygen.value = 100
	stamina.value = 100
	updateLabels()


func _process(delta):
	player.health += player.healthRegeneration
	healthModified()
	supplies.value -= delta * player.supplyDrain
	oxygen.value -= delta * player.oxygenDrain
	stamina.value -= delta * (player.staminaDrain - player.staminaRestore)
	if (supplies.value <= 0 && !suppliesBeingRestocked):
		suppliesBeingRestocked = true
		$"SuppliesTimer".start()
		player.inventory.removeResource(allResources.resources[0], 1)
		updateLabels()
		get_tree().create_tween().tween_property(supplies, "value", 100, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	if (oxygen.value <= 0):
		pass
	if (stamina.value <= 0):
		pass

func updateHud(suppliesValue, staminaValue, oxygenValue):
	if !suppliesBeingRestocked:
		get_tree().create_tween().tween_property(supplies, "value", supplies.value - suppliesValue, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(oxygen, "value", oxygen.value - oxygenValue, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	get_tree().create_tween().tween_property(stamina, "value", stamina.value - staminaValue, 0.15).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func healthModified():
	get_tree().create_tween().tween_property(health, "value", player.health / player.maxHealth * 100, 0.25).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func updateLabels():
	suppliesLabel.text = str(player.inventory.getResource(allResources.resources[0]))
	oxygenLabel.text = str(player.inventory.getResource(allResources.resources[1]))
	staminaLabel.text = str(player.inventory.getResource(allResources.resources[2])) 


func _on_supplies_timer_timeout():
	suppliesBeingRestocked = false
