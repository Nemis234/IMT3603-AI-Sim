extends Node2D

@onready var mainmenu: Control = $MainMenu

func _ready():
	pass
	#Load the mainmenu upon start
	#load_and_switch_scene_from_path("res://scenes/UI/MainMenu/main_menu.tscn")
	
# Load the given scene
func load_and_switch_scene_from_path(path: String):
	get_tree().change_scene_to_file(path)
