extends Control
const CHARACTER_MENU = preload("res://scenes/UI/CharacterMenu/character_menu.tscn")

#Quits game upon press
func _on_quit_pressed() -> void:
	get_tree().quit()

#Change scene to active game
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(CHARACTER_MENU)
