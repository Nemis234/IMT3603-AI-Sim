extends CharacterBody2D

signal interact(agent,interactable)

@onready var detectionArea: Area2D = $Area2D
@export var movement_speed = 5000

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var agentActions: AgentActionListComponent

#Agents house related
@export var house: Node2D
var house_entrance
var house_exit

#Agents action related
var current_action # Stores the agents current action 
var in_building: bool = false #Bool for when agent is insie or outside
@onready var agent_interact_area = $InteractArea

func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Entrance")
	house_exit = house.get_node("house_interior").get_node("Entrance")

func _physics_process(delta: float) -> void:
	pathfindingComponent.move_along_path(delta)
	movementAnimation.update_animation(velocity)
	

#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	match current_action:
		"Wander":
			agentActions.agent_action_done = true
		"GoHome":
			if in_building == false:
				var door_entrance = agent_interact_area.get_overlapping_areas()[0].get_parent()
				interact.emit(self, door_entrance)
				in_building = true
				agentActions.agent_action_done = true
		"LeaveHome":
			if in_building:
				var door_entrance = agent_interact_area.get_overlapping_areas()[0].get_parent()
				interact.emit(self, door_entrance)
				in_building = false
				agentActions.agent_action_done = true
		_:
			pass

#Set a new action for agent, as for now its based on a time interval
func new_agent_action():
	if !agentActions.agent_action_done:
		return
	
	var new_action = agentActions.agent_actions.pick_random()
	
	while agentActions.is_invalid_action(new_action, in_building):
		new_action = agentActions.agent_actions.pick_random()
	
	match new_action:
		"Wander":
			if agentActions.agent_action_done and !in_building:
				pathfindingComponent.set_target(randomVectorOnNavigationLayer.get_random_target_main_map())
				agentActions.agent_action_done = false
			elif agentActions.agent_action_done and in_building:
				pathfindingComponent.set_target(randomVectorOnNavigationLayer.get_random_target_in_building("House"))
				agentActions.agent_action_done = false
		"GoHome":
			pathfindingComponent.set_target(house_entrance.get_global_position())
			agentActions.agent_action_done = false
		"LeaveHome":
			pathfindingComponent.set_target(house_exit.get_global_position())
			agentActions.agent_action_done = false
		"Idle": 
			pass
		_:print("No such action")
	
	current_action = new_action


func _on_interact_area_area_entered(area: Area2D) -> void:
	#Opens doors automatically whenever close to a door 
	if area.get_parent().is_in_group("Doors"):
		if area.get_parent().curr_state == 0:
			area.get_parent().change_state()


func _on_interact_area_area_exited(area: Area2D) -> void:
	#Closing doors automatically whenever leaving door area 
	if area.get_parent().is_in_group("Doors"):
		if area.get_parent().curr_state == 1:
			area.get_parent().change_state()
