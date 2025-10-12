extends CharacterBody2D

signal interact(agent,interactable)

@onready var interactionArea: Area2D = $InteractArea
@onready var objectDetectionArea: Area2D = $ObjectDetection
@export var movement_speed = 5000

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var agentActions: AgentActionListComponent

#Agents house/building related
@export var house: Node2D
var house_entrance
var house_exit
var in_building: Node2D #Stores the building the agent is in.

#Agents action related
@onready var agent_interact_area = $InteractArea

func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Entrance")
	house_exit = house.get_node("house_interior").get_node("Entrance")

func _physics_process(delta: float) -> void:
	pathfindingComponent.move_along_path(delta)
	movementAnimation.update_animation(velocity)
	

#Helper function to loop through objects and return a specific node
func get_interactable_object(node_list: Array,group: String ,node_name: String) -> Node2D:
	for node in node_list:
		if node.name == node_name:
			print(node)
			return node
	
	##TODO Maybe create one to filter by group aswell
	return null

#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	match agentActions.current_action:
		"Wander":
			agentActions.agent_action_done = true
		"GoHome":
			if in_building == null:
				var door_entrance = get_interactable_object(agent_interact_area.get_overlapping_areas(),"","Entrance").get_parent()
				interact.emit(self, door_entrance)
				in_building = house
				agentActions.agent_action_done = true
		"LeaveHome":
			if in_building:
				var door_entrance = get_interactable_object(agent_interact_area.get_overlapping_areas(),"","Entrance").get_parent()
				interact.emit(self, door_entrance)
				in_building = null
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
	
	agentActions.current_action = new_action


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


func _on_object_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("interactable") and not area.get_parent().is_in_group("Doors"):
		agentActions.interactable_objects[area.get_parent()] = {
			"building": in_building, 
			"position": area.get_global_position(), 
			"name": area.get_parent().name
			}
