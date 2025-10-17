extends Node
class_name AgentActionListComponent

#Agent actions related
@onready var agentNode: Node2D = $".."

#A dictionary of objects and their position
var interactable_objects: Dictionary = {
	#ObjectNodePath { "building": Null? , "position": Vectori2, "name": node.name }
}
var agent_actions: Array = [
	"wander", 
	"idle", 
	"gohome", 
	"leavebuilding", 
	"read",
	"eat", 
	"sleep"
	]
var agent_action_done: bool = true
var current_action # Stores the agents current action 
var queued_action = "" # Stores the next action, for cases such as entering house to read from bookshelf

#Check if agent remembers a specific object
func is_object_in_memory(objectName: String) -> Dictionary:
	for key in interactable_objects.keys():
		var object = interactable_objects[key]
		if object["name"].to_lower().contains(objectName.to_lower()):
			#TODO this will always return the first object of its kind
			#maybe change the logic later?
			return {
				"node": object, 
				"building": object["building"], 
				"position": object["position"], 
				"name": object["name"]
				}
	return {}

##Helper function. This is used to filter out unavailable actions
##home is the agents home
##in_building is either null or a Node2D, which is the building the agent is currently in.
##partOfDay is passed from the levelmanager
func _filter_action_list(home: Node2D, in_building: Node2D) -> Array:
	var filtered_action_list = agent_actions.duplicate()

	# Day Night Cycle Related filtering
	if Global.partOfDay.to_lower() == "night":
		filtered_action_list = ["gohome", "sleep"]
		
	# Building-related filtering
	if in_building == home:
		filtered_action_list.erase("gohome")
	elif in_building == null:
		filtered_action_list.erase("leavebuilding")
		
	# Detect which objects exist in memory
	var has_bookshelf := false
	var has_fridge := false
	var has_bed := false

	for key in interactable_objects.keys():
		var objectData = interactable_objects[key]
		if objectData.has("name"):
			var name = objectData["name"].to_lower()
			if name.find("bookshelf") != -1:
				has_bookshelf = true
			if name.find("fridge") != -1:
				has_fridge = true
			if name.find("bed") != -1:
				has_bed = true

	# Remove actions when their required object is missing
	if not has_bookshelf:
		filtered_action_list.erase("read")
	if not has_fridge:
		filtered_action_list.erase("eat")
	if not has_bed:
		filtered_action_list.erase("sleep")

	return filtered_action_list


##Ask AI LLM for a new action
##home is need to filter out certain action, such as go home
##in_building is needed to filter out unavailable actions
##partOfDay is passed from the levelmanager
##command_stream is the output of the request
func prompt_new_action(home: Node2D,in_building: Node2D ,command_stream: Label) -> String:
	var filtered_action_list = _filter_action_list(home, in_building)

	if in_building == home:
		filtered_action_list.erase("gohome")
	elif in_building == null:
		filtered_action_list.erase("leavebuilding")
	
	var text_prompt = "Pick an action from this array that you feel like should be done now " + str(filtered_action_list) + ". Ouput only the action"
	
	# Clear previous command
	command_stream.text = ""
	
	if !agentNode.agentName:
		print("Agent is missing a name")
		return ""

	# Send prompt and wait for response
	#NEW: Set type to action to send request to /action endpoint
	await ServerConnection.post_message(agentNode.agentName,text_prompt, command_stream, "action") 
	
	# Make sure response is not empty
	while command_stream.text == "":
		await get_tree().process_frame  # wait one frame before checking again
	
	return str(command_stream.text).strip_edges().to_lower()

#This is the old logic, randomly picking actions, this is mainly for debugging/testing
func pick_random_action(home: Node2D,in_building: Node2D) -> String:
	var filtered_action_list = _filter_action_list(home, in_building)

	if in_building == home:
		filtered_action_list.erase("gohome")
	elif in_building == null:
		filtered_action_list.erase("leavebuilding")
		
	return filtered_action_list.pick_random()
