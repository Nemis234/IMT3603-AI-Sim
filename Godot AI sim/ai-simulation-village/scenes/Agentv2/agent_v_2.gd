extends CharacterBody2D

@onready var detectionArea: Area2D = $Area2D
@onready var navigationNode: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed = 5000
@export var target: Vector2 

#testing can delete later
var this_guys_house
func _ready() -> void:
	for houses in get_tree().get_nodes_in_group("Houses_Main_Map"):
		if houses.name == "HouseOverworld":
			this_guys_house = houses

func _physics_process(delta: float) -> void:
	#TODO
	navigationNode.target_position = this_guys_house.get_node("Entrance").get_node("EntrancePosition").get_global_position()
	
	if !navigationNode.is_target_reached():
		var direciton = to_local(navigationNode.get_next_path_position()).normalized()
		velocity = direciton * movement_speed * delta
		move_and_slide()
	

 
#testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == 69:
			for entities in detectionArea.get_overlapping_areas():
				if entities.get_parent().is_in_group("interactable"):
					entities.get_parent().change_state()
				if entities.get_parent().is_in_group("Houses_Main_Map"):
					self.position = entities.get_parent().entrance_position
					navigationNode.target_position = entities.get_parent().entrance_position
					print("Enters house")
