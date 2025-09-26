extends StaticBody2D

#The global positions to move player/agent to, when entering the house
@onready var entrance_position: Vector2 = $HouseInterior/Entrance/EntrancePosition.get_global_position()

#The global position to move player/agent to, when leaving the house 
@onready var overworld_position: Vector2 = $Entrance/EntrancePosition.get_global_position()
