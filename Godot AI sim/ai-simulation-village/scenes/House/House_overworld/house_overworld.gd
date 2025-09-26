extends StaticBody2D

@onready var door_area: Area2D = $Area2D

#The global position to move player/agent to, when leaving the house 
var overworld_position: Vector2 

#The global positions to move player/agent to, when entering the house
var entrance_position: Vector2

func _ready() -> void:
	overworld_position = door_area.get_global_position()
	
	for houses in get_tree().get_nodes_in_group("House"):
		print(houses)
		#if houses.name == "House":
			#entrance_position = houses.get_node("Entrance").get_child("EntrancePosition").get_global_position()
