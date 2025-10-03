extends CharacterBody2D

@onready var detectionArea: Area2D = $Area2D
@export var movement_speed = 5000

@export var pathfindingComponent: PathfindingComponent
@export var house: Node2D

var house_entrance

func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Area2D")
	pathfindingComponent.set_target(house_entrance.get_global_position())

func _physics_process(delta: float) -> void:
	pathfindingComponent.move_along_path(delta)

	
