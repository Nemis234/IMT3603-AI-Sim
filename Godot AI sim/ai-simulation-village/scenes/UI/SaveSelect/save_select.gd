extends Control

func change_to_level_manager() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelManager/level_manager.tscn")

func change_to_character_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/CharacterMenu/character_menu.tscn")

# To check if the save exists
func save_exists(save_path: String) -> bool:
	return FileAccess.file_exists(save_path)
		

# If save exists go to level manager 
func change_to_scene_based_on_save(save_path:String):
	if save_exists(save_path):
		change_to_level_manager()
	else:
		change_to_character_menu()

func convert_time(time) -> String:
	var totalMinutes = time * 1440.0
	var minute = int(totalMinutes) % 60
	var hour = int(totalMinutes / 60) % 24
	@warning_ignore("integer_division")
	var day = int(int(totalMinutes / 60) / 24) + 1 

	return "Day %s Time: %s:%s" % [day,hour,minute]



func _ready():
	for slot in range(1,4):
		var delete_button = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Slot%s/Delete" % slot)
		delete_button.pressed.connect(_on_delete_pressed.bind(slot))
	
	update_slots()

# Indicate for whther slot has a save
func update_single_slot(slot:int) -> void:
	var label = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Slot%s/Label" % slot)
	var delete_button = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Slot%s/Delete" % slot)
	
	
	var save_path: String = "user://villSim_%d.save" % slot

	if save_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close() 

		label.text = data["player_details"]["character"] + " " + convert_time(data["time"]) 
		delete_button.disabled = false
	else:
		label.text = "Empty slot"
		delete_button.disabled = true

func update_slots()-> void:
	for slot in range(1,4):  #3 slots
		update_single_slot(slot)

# Delete an exisiting save
func delete_slot(slot: int):
	var save_path: String = "user://villSim_%d.save" % slot
	
	if save_exists(save_path):
		var err = DirAccess.remove_absolute(save_path)
		if err == OK:
			print("Deleted save %s" % save_path)
		else:
			print("Failed to delete save %s" % save_path)
	
	update_single_slot(slot) #update the specific slot data

func _on_save_1_pressed() -> void:
	Global.selected_save = "user://villSim_%d.save" % 1
	ServerConnection.send_save_slot(1,"create")
	change_to_scene_based_on_save(Global.selected_save)
	

func _on_save_2_pressed() -> void:
	Global.selected_save = "user://villSim_%d.save" % 2
	ServerConnection.send_save_slot(2,"create")
	change_to_scene_based_on_save(Global.selected_save)
	

func _on_save_3_pressed() -> void:
	Global.selected_save = "user://villSim_%d.save" % 3
	ServerConnection.send_save_slot(3,"create")
	change_to_scene_based_on_save(Global.selected_save)
	

func _on_delete_pressed(slot) -> void:
	delete_slot(slot)
	ServerConnection.send_save_slot(slot,"delete")
