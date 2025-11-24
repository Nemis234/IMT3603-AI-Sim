extends Node2D

@export var house_interior: Node2D
@export var house_exterior: Node2D


@onready var door_area: Area2D = house_exterior.get_node("Entrance")
@onready var exit_area: Area2D = house_interior.get_node("Entrance")

@onready var navigationTilesMainFloor: TileMapLayer

func _ready() -> void:
	
	#Single story house
	navigationTilesMainFloor = house_interior.get_node("WalkAbleTiles")
	
	#For houses with more stories
	if house_interior.get_node("main_floor"):
		navigationTilesMainFloor = house_interior.get_node("main_floor").get_node("WalkAbleTiles")
		## TODO Add walkable tiles for 2nd floors later
