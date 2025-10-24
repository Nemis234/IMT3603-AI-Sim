extends Node
class_name AgentActionInteractionComponent

signal interact(agent,interactable)

#The agent this component is bounded too
var agent: CharacterBody2D

func _ready():
	agent = get_parent() as CharacterBody2D

##Helper function to loop through objects and return a specific node
##group is the group the object belongs to, it can be passed as "" to ignore group
##objectName name of the object to interact with.
func get_interactable_object(group:String, objectName: String) -> Node2D:
	var node_list = agent.agent_interact_area.get_overlapping_areas()
	
	#Mainly used to get entrances, and other nodes who does not have a parent
	if group == "":
		for node in node_list:
			if node.name.to_lower().contains(objectName.to_lower()):
				return node.get_parent()
	elif group == "interactable":
		for node in node_list:
			if node.get_parent().name.to_lower().contains(objectName.to_lower()):
				return node.get_parent()
	
	return null

##Helper function. Finds an object around the agent with the correct name and interacts with object.
##group is the group the object belongs to, it can be passed as "" to ignore group
##objectName name of the object to interact with.
func _interact_with_object(group: String, objectName: String) -> void:
	var object = get_interactable_object(group, objectName)
	
	if object:		
		interact.emit(agent, object)
		if objectName.to_lower() == "entrance":
			agent.agent_action_done = true
			if agent.current_action.to_lower() == "leavebuilding":
				agent.in_building = null
			else :
				agent.in_building = object.get_parent()
		else:
			#If the object is not and entrance, delay agent action
			#to mimic time to perform action
			print("Time started")
			agent.agentStats.show_progress_bar()
			await _delay_agent_action(agent.duration_action, true)
			agent.agent_action_done = true
			print("Time ended")
	else:
		#Agent will only get here if they are standing outside of the house
		#while waiting to enter building to interact with object
		if group == "interactable":
			var door_entrance = get_interactable_object("","Entrance")
			interact.emit(agent, door_entrance)
			agent.in_building = door_entrance.get_parent()
			agent.queued_action = agent.current_action
			agent.agent_action_done = true
			
##Function used to delay agent actions. Used to mimic time an agent would use to interact
##with an object. Also used to update stats(TODO Maybe seperate them later)
func _delay_agent_action(duration, usingObject = null):
	duration = float(duration)
	while duration > 0:
		if usingObject:
			agent.agentStats.update_stat(agent.current_action) #TODO optimalize this
		duration -= get_process_delta_time() * (1440 / Global.realSecondsPerIngameDay)
		await get_tree().process_frame
