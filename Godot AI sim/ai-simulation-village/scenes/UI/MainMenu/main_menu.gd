extends Control
const LEVEL_MANAGER = preload("uid://t6oxthatfx7e")

#Quits game upon press
func _on_quit_pressed() -> void:
	get_tree().quit()

#Change scene to active game
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_MANAGER)
