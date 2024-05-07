extends Node2D


func _ready():
	return
	var texture1 = preload("res://assets/environment/textures/noise/noise1.tres")
	var texture2 = preload("res://assets/environment/textures/noise/noise2.tres")
	var texture3 = preload("res://assets/environment/textures/noise/noise3.tres")
	saveImage(texture1, "noise1")
	saveImage(texture2, "noise2")
	saveImage(texture3, "noise3")


func saveImage(texture, path):
	await texture.changed
	var image = texture.get_image()
	var data = image.get_data()
	image.save_png("res://assets/environment/textures/noise/" + path + ".png")
