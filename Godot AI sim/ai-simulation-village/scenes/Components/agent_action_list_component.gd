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
	"sleep",
	"visit"
	]

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
func _filter_action_list(home: Node2D, in_building: Node2D, stats: Dictionary) -> Array:
	var filtered_action_list = agent_actions.duplicate()
	
	# Day Night Cycle Related filtering and stat priority based filtering
	match Global.partOfDay.to_lower():
		"morning":
			filtered_action_list = ["eat"]
		"night":
			filtered_action_list = ["gohome", "sleep"]
		_:
			#Filtering actions based on stats
			for key in stats.keys():
				var stat = stats[key]
				if stat > 30:
					match key:
						"mood": filtered_action_list.erase("read")
						"hunger": filtered_action_list.erase("eat")
						"tiredness": filtered_action_list.erase("sleep")

		
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
			var object_name = objectData["name"].to_lower()
			if object_name.find("bookshelf") != -1:
				has_bookshelf = true
			if object_name.find("fridge") != -1:
				has_fridge = true
			if object_name.find("bed") != -1:
				has_bed = true

	# Remove actions when their required object is missing
	if not has_bookshelf:
		filtered_action_list.erase("read")
	if not has_fridge:
		filtered_action_list.erase("eat")
	if not has_bed:
		filtered_action_list.erase("sleep")
		
	#TODO Maybe use a weight system later
	#Filtering out low weighted actions
	if randf() < 0.7: #70% to filter out
		filtered_action_list.erase("wander")
		filtered_action_list.erase("idle")
	
	return filtered_action_list


##Ask AI LLM for a new action
##home is need to filter out certain action, such as go home
##in_building is needed to filter out unavailable actions
##partOfDay is passed from the levelmanager
##command_stream is the output of the request
func prompt_new_action(home: Node2D,in_building: Node2D, stats: Dictionary ,command_stream: Label) -> Dictionary:
	var filtered_action_list = _filter_action_list(home, in_building, stats)
	
	#var text_prompt = str(filtered_action_list)

	# Clear previous command
	command_stream.text = ""
	
	if !agentNode.agentName:
		print("Agent is missing a name")
		return {}
	var h = Global.hour
	var hour = "0"+ str(h) if h < 10 else str(h)
	var m = Global.minute
	var minute = "0"+str(m) if m < 10 else str(m)

	var agent_details:Dictionary = {
		"agent": str(agentNode.agentName),
		"location": str(agentNode.currentLocation),
		"time":hour + ":" + minute,
		"action_list": filtered_action_list,
		"visit_list": Global.agent_houses # Dicitonary {}
		}
	# Send prompt and wait for response
	#NEW: Set type to action to send request to /action endpoint
	await ServerConnection.post_action(agent_details, command_stream) 
	
	# Make sure response is not empty
	while command_stream.text == "":
		await get_tree().process_frame  # wait one frame before checking again
	
	#NEW: Response stream for actions now is a json so getting relevant info from others
	var action_info = JSON.parse_string(command_stream.text) # is a dict = {"action": ..., "duration": ...}
	#print(action_info)
	action_info["action"] = action_info["action"].strip_edges().to_lower() #The action 
	action_info["duration"] = int(action_info["duration"]) #NEW: How long the agent should perform the action
	

	return action_info

#This is the old logic, randomly picking actions, this is mainly for debugging/testing
func pick_random_action(home: Node2D,in_building: Node2D, stats: Dictionary) -> String:
	var filtered_action_list = _filter_action_list(home, in_building, stats)

	return filtered_action_list.pick_random()
