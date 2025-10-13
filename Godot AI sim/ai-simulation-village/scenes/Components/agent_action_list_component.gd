extends Node
class_name AgentActionListComponent

#Agent actions related
#A dictionary of objects and their position
var interactable_objects: Dictionary = {
	#ObjectNodePath { "building": Null? , "position": Vectori2, "name": node.name }
}
var agent_actions: Array = [
	"Wander", 
	"Idle", 
	"GoHome", 
	"LeaveHome", 
	"Read" 
	#"Eat", 
	#"Sleep"
	]
var agent_action_done: bool = true
var current_action # Stores the agents current action 

#For now, prevents agent from going home whenever they are home
#and also leave home, whenever they are already outside
func is_invalid_action(new_action: String, in_building: Node2D) -> bool:
	return (new_action == "GoHome" and in_building) or (new_action == "LeaveHome" and !in_building)

#Check if agent remembers a specific object
func is_object_in_memory(objectName: String) -> Dictionary:
	for key in interactable_objects.keys():
		var object = interactable_objects[key]
		if object["name"].to_lower().contains(objectName.to_lower()):
			return {
				"node": object, 
				"building": object["building"], 
				"position": object["position"], 
				"name": object["name"]
				}
	return {}
