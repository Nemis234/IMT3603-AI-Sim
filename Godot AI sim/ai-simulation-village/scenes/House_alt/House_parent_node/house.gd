extends Node2D

@export var house_interior: Node2D
@export var house_exterior: Node2D


@onready var door_area: Area2D = house_exterior.get_node("Entrance")
@onready var exit_area: Area2D = house_interior.get_node("Entrance")

@onready var navigationTilesMainFloor: TileMapLayer = house_interior.get_node("WalkAbleTiles")
