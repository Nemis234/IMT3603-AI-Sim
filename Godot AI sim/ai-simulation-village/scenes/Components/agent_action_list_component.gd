extends Node
class_name AgentActionListComponent

#Agent actions related
var agent_actions: Array = ["Wander", "Idle", "GoHome", "LeaveHome"]
var agent_action_done: bool = true

#For now, prevents agent from going home whenever they are home
#and also leave home, whenever they are already outside
func is_invalid_action(new_action: String, in_building: bool) -> bool:
	return (new_action == "GoHome" and in_building) or (new_action == "LeaveHome" and !in_building)
