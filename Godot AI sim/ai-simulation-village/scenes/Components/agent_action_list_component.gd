extends Node
class_name AgentActionListComponent

#Agent actions related
#A dictionary of objects and their position
var interactable_objects: Dictionary = {
	#ObjectNodePath { "building": Null? , "position": Vectori2, "name": node.name }
}
var agent_actions: Array = [
	"wander", 
	"idle", 
	"gohome", 
	"leavebuilding", 
	"read" 
	#"eat", 
	#"sleep"
	]
var agent_action_done: bool = true
var current_action # Stores the agents current action 
var queued_action = "" # Stores the next action, for cases such as entering house to read from bookshelf

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

##Ask AI LLM for a new action
##home is need to filter out certain action, such as go home
##in_building is needed to filter out unavailable actions
##command_stream is the output of the request
func prompt_new_action(home: Node2D,in_building: Node2D, command_stream: Label) -> String:
	var filtered_action_list = agent_actions.duplicate()
	
	if in_building == home:
		filtered_action_list.erase("gohome")
	elif in_building == null:
		filtered_action_list.erase("leavebuilding")
	
	print(filtered_action_list)
	var text_prompt = "Can you pick a random action from this array?" + str(filtered_action_list)
	
	# Clear previous command
	command_stream.text = ""
	
	# Send prompt and wait for response
	await ServerConnection.post_message(text_prompt, command_stream)
	
	# Make sure response is not empty
	while command_stream.text == "":
		await get_tree().process_frame  # wait one frame before checking again
	
	return str(command_stream.text).strip_edges().to_lower()
