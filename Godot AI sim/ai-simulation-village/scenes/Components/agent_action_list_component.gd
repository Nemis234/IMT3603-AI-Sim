extends Node
class_name AgentActionListComponent

#Agent actions related
var interactable_objects: Dictionary = {} #A dictionary of objects and their position
var agent_actions: Array = ["Wander", "Idle", "GoHome", "LeaveHome"]
var agent_action_done: bool = true
var current_action # Stores the agents current action 

#For now, prevents agent from going home whenever they are home
#and also leave home, whenever they are already outside
func is_invalid_action(new_action: String, in_building: Node2D) -> bool:
	return (new_action == "GoHome" and in_building) or (new_action == "LeaveHome" and !in_building)
