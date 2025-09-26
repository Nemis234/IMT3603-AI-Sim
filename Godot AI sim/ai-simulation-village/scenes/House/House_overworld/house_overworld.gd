extends StaticBody2D

@onready var door_area: Area2D = $Area2D

#The global positions to move player/agent to, when entering the house
@onready var entrance_position: Vector2 = $House/Entrance/EntrancePosition.get_global_position()

#The global position to move player/agent to, when leaving the house 
var overworld_position: Vector2 


func _ready() -> void:
	overworld_position = door_area.get_global_position()
	print(entrance_position)
