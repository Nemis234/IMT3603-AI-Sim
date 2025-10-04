extends CharacterBody2D

@onready var detectionArea: Area2D = $Area2D
@export var movement_speed = 5000

@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var house: Node2D

var house_entrance

#Agent actions related, might make a new component out of this later
var agent_actions: Array = ["Wander", "Idle"]
var agent_action_done: bool = true

func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Area2D")
	

func _physics_process(delta: float) -> void:
	pathfindingComponent.move_along_path(delta)


#For now set a new target upon reaching target
func _on_pathfinding_component_target_reached() -> void:
	agent_action_done = true
	#pathfindingComponent.set_target(randomVectorOnNavigationLayer.get_random_target_main_map())

#Set a new action for agent, as for now its based on a time interval
func new_agent_action():
	var new_action = agent_actions.pick_random()

	match new_action:
		"Wander":
			if agent_action_done:
				pathfindingComponent.set_target(randomVectorOnNavigationLayer.get_random_target_main_map())
				agent_action_done = false
		"Idle": pass
		_:print("No such action")
