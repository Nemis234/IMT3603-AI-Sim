extends Node
class_name PathfindingComponent

signal target_reached

@export var navigationNode: NavigationAgent2D
@export var movement_speed: float = 50

#The agent this component is bounded too
var agent: CharacterBody2D

#Bool to control emits
var _has_emitted: bool = false

func _ready():
	agent = get_parent() as CharacterBody2D

func set_target(new_target: Vector2):
	navigationNode.target_position = new_target
	_has_emitted = false

func move_along_path(_delta: float) -> void:
	if !navigationNode.is_target_reached():
		var direction = agent.to_local(navigationNode.get_next_path_position()).normalized()
		var new_velocity = direction * movement_speed
		
		#This part is to avoid agents getting stuck onto each other
		if navigationNode.avoidance_enabled:
			navigationNode.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		#agent.move_and_slide()
	else:
		agent.velocity = Vector2.ZERO
		if !_has_emitted:
			target_reached.emit() #Emits signal that target is reached
			_has_emitted = true
			
func get_target_reached() -> bool:
	return navigationNode.is_target_reached()

##Helper function to set target desitnation and set the agent_action_done to false.
##This is used for simple "go to this point"-actions.
##target is the end-destination in vector.
func _go_to_target(target: Vector2i)-> void:
	set_target(target)
	agent.agent_action_done = false
	
##Helper function to move agents to objects.
##This function is mainly used to move agent to an object such as bookshelfs.
##object is the interactable object that is needed for the action that triggered this function.
##action is the action which triggered this function.
func _got_to_object(action: String) -> void:
	var object: String
	match action:
		"read": 
			object = "bookshelf"
		"eat":
			object = "fridge"
		"sleep":
			object = "myownbed"
		"visit":
			object = "placehold for now, wait until i know what the data looks like"
	
	var interactable_object = agent.actionList.is_object_in_memory(object)
	if interactable_object:
		#If agent is in the same building as the object
		if agent.in_building == interactable_object["building"]:
			_go_to_target(interactable_object["position"])
		#If agent is in another building but not in the same as the object
		elif agent.in_building != interactable_object["building"] and agent.in_building != null:
			_go_to_target(agent.in_building.get_node("house_interior").get_node("Entrance").get_global_position())
			agent.new_action = "leavebuilding"
			agent.current_action = agent.new_action
			agent.queued_action = action.to_lower()
		#If agent is outside
		else:
			_go_to_target(interactable_object["building"].get_node("house_exterior").get_node("Entrance").get_global_position())

	else:
		print("No " + object +  " in memory")

##This is related to navigation avoidance
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	agent.velocity = safe_velocity
