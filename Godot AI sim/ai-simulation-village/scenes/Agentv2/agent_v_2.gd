class_name Agent
extends CharacterBody2D

signal interact(agent,interactable)

@onready var agent_interact_area: Area2D = $InteractArea
@onready var objectDetectionArea: Area2D = $ObjectDetection

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var agentActions: AgentActionListComponent

@onready var speechBubble = $SpeechBubble
@onready var speechLabel = $SpeechBubble/Control/PanelContainer/ScrollContainer/MarginContainer/Label

#Agent identifications
@export var agentName: String

#Agents house/building related
@export var house: Node2D
var house_entrance
@onready var in_building: Node2D = house #Stores the building the agent is in.

#Agents action related
var new_action
var current_action # Stores the agents current action 
var is_requesting_action:bool = false #Helps with overrequesting actions
var in_dialogue: bool = false #To check if agent in dialogue
@onready var command_stream = $AICommand

#Progressbar and stats related
@export var agentStats: AgentStatComponent

#To store the current location of the agent (in context if the world)
@onready var currentLocation = house.name 


func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Entrance")
	
	agent_interact_area.body_entered.connect(_on_interact_area_entered)
	agent_interact_area.body_exited.connect(_on_interact_area_exited)


func _physics_process(delta: float) -> void:
	if in_dialogue:
		movementAnimation.update_animation(Vector2.ZERO)
		return
	
	pathfindingComponent.move_along_path(delta)
	movementAnimation.update_animation(velocity)
	

##Helper function to loop through objects and return a specific node
##group is the group the object belongs to, it can be passed as "" to ignore group
##objectName name of the object to interact with.
func get_interactable_object(group:String, objectName: String) -> Node2D:
	var node_list = agent_interact_area.get_overlapping_areas()
	
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
		interact.emit(self, object)
		agentActions.agent_action_done = true
		agentStats.update_stat(current_action)
		if objectName.to_lower() == "entrance":
			if current_action.to_lower() == "leavebuilding":
				in_building = null
			else :
				in_building = object.get_parent()
	else:
		#Agent will only get here if they are standing outside of the house
		#while waiting to enter building to interact with object
		if group == "interactable":
			var door_entrance = get_interactable_object("","Entrance")
			interact.emit(self, door_entrance)
			in_building = door_entrance.get_parent()
			agentActions.queued_action = current_action
			agentActions.agent_action_done = true
		
		
#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	match current_action:
		"wander":
			agentActions.agent_action_done = true
		"gohome":
				_interact_with_object("","entrance")
		"leavebuilding":
				_interact_with_object("","entrance")
		"read": 
			_interact_with_object("interactable","bookshelf")
		"eat":
			_interact_with_object("interactable","fridge")
		"sleep":
			_interact_with_object("interactable", "bed")
		_:
			pass
		

##Set a new action for agent. Actions can either be picked random or by an AI Model (Gemini).
##To switch between set-type, toggle between the commented "new_action = ..."
##partOfDay is to check for available actions
func new_agent_action():
	if !agentActions.agent_action_done or is_requesting_action:
		return
	
	is_requesting_action = true
	agentStats.hide_progress_bar()
		
	if agentActions.queued_action == "":
		var action_details = await agentActions.prompt_new_action(house,in_building,agentStats.stats,command_stream) # Enable this for AI controlling
		new_action = action_details["action"]
		var duration = action_details["duration"] #Expected Duration to perform action in minutes
		
		#new_action = agentActions.pick_random_action(house, in_building, agentStats.stats) #Enable this to pick randomly without AI
	else:
		new_action = agentActions.queued_action
		agentActions.queued_action = ""
	
	match new_action:
		"wander":
			if !in_building:
				_go_to_target(randomVectorOnNavigationLayer.get_random_target_main_map())
			elif in_building:
				_go_to_target(randomVectorOnNavigationLayer.get_random_target_in_building(in_building))
		"gohome":
			_go_to_target(house_entrance.get_global_position())
		"leavebuilding":
			_go_to_target(in_building.get_node("house_interior").get_node("Entrance").get_global_position())
		"read": 
			_got_to_object("bookshelf", "read")
		"eat":
			_got_to_object("fridge", "eat")
		"sleep":
			#TODO will agents have a designated bed?
			_got_to_object("bed", "sleep")
		"idle": 
			pass
		_:print("No such action")
	
	is_requesting_action = false
	current_action = new_action

##Helper function to set target desitnation and set the agent_action_done to false.
##This is used for simple "go to this point"-actions.
##target is the end-destination in vector.
func _go_to_target(target: Vector2i)-> void:
	pathfindingComponent.set_target(target)
	agentActions.agent_action_done = false
	
##Helper function to move agents to objects.
##This function is mainly used to move agent to an object such as bookshelfs.
##object is the interactable object that is needed for the action that triggered this function.
##action is the action which triggered this function.
func _got_to_object(object: String, action: String) -> void:
	var interactable_object = agentActions.is_object_in_memory(object)
	if interactable_object:
		if in_building == interactable_object["building"]:
			_go_to_target(interactable_object["position"])
		elif in_building != interactable_object["building"] and in_building != null:
			_go_to_target(in_building.get_node("house_interior").get_node("Entrance").get_global_position())
			new_action = "leavebuilding"
			current_action = new_action
			agentActions.queued_action = action.to_lower()
		else:
			_go_to_target(interactable_object["building"].get_node("house_exterior").get_node("Entrance").get_global_position())
	else:
		print("No " + object +  " in memory")

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
			"position": area.get_parent().get_node("Marker2D").get_global_position(), 
			"name": area.get_parent().name
			}
		
func _on_interact_area_entered(body):
	if body.is_in_group("Player"):
		body.curr_interactable = self


func _on_interact_area_exited(body):
	if body.is_in_group("Player"):
		body.curr_interactable = null

func hide_speech():
	speechBubble.visible = false
	speechLabel.text = ""

func stream_speech(text:String):
	speechBubble.visible = true
	ServerConnection.post_message(agentName,text,speechLabel)
	
