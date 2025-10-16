class_name Agent
extends CharacterBody2D

signal interact(agent,interactable)

@onready var agent_interact_area: Area2D = $InteractArea
@onready var objectDetectionArea: Area2D = $ObjectDetection
#@export var movement_speed = 100

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var agentActions: AgentActionListComponent

@onready var speechBubble = $SpeechBubble
@onready var speechLabel = $SpeechBubble/Control/PanelContainer/ScrollContainer/MarginContainer/Label

#Agents house/building related
@export var house: Node2D
var house_entrance
var in_building: Node2D #Stores the building the agent is in.

#Agents action related
var new_action
var current_action # Stores the agents current action 
var is_requesting_action:bool = false #Helps with overrequesting actions
var in_dialogue: bool = false #To check if agent in dialogue
@onready var command_stream = $AICommand


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
	

#Helper function to loop through objects and return a specific node
func get_interactable_object(group:String, node_name: String) -> Node2D:
	var node_list = agent_interact_area.get_overlapping_areas()
	
	#Mainly used to get entrances, and other nodes who does not have a parent
	if group == "":
		for node in node_list:
			if node.name.to_lower().contains(node_name.to_lower()):
				return node.get_parent()
	elif group == "interactable":
		for node in node_list:
			if node.get_parent().name.to_lower().contains(node_name.to_lower()):
				return node.get_parent()
	
	#TODO Maybe create one to filter by group aswell
	return null

#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	match agentActions.current_action:
		"wander":
			agentActions.agent_action_done = true
		"gohome":
			if in_building == null:
				var door_entrance = get_interactable_object("","Entrance")
				interact.emit(self, door_entrance)
				in_building = house
				agentActions.agent_action_done = true
		"leavebuilding":
			if in_building:
				var door_entrance = get_interactable_object("","Entrance")
				interact.emit(self, door_entrance)
				in_building = null
				agentActions.agent_action_done = true
		"read": 
			var bookshelf = get_interactable_object("interactable","bookshelf")
			if bookshelf:
				interact.emit(self, bookshelf)
				agentActions.agent_action_done = true
			else:
				var door_entrance = get_interactable_object("","Entrance")
				interact.emit(self, door_entrance)
				in_building = door_entrance.get_parent()
				agentActions.queued_action = "Read"
				agentActions.agent_action_done = true
		_:
			pass

#Set a new action for agent, as for now its based on a time interval
func new_agent_action():
	if !agentActions.agent_action_done or is_requesting_action:
		return
		
	is_requesting_action = true
		
	if agentActions.queued_action == "":
		new_action = await agentActions.prompt_new_action(house,in_building, command_stream)
	else:
		new_action = agentActions.queued_action
		agentActions.queued_action = ""
	
	match new_action:
		"wander":
			if agentActions.agent_action_done and !in_building:
				_go_to_target(randomVectorOnNavigationLayer.get_random_target_main_map())
			elif agentActions.agent_action_done and in_building:
				_go_to_target(randomVectorOnNavigationLayer.get_random_target_in_building("House"))
		"gohome":
			_go_to_target(house_entrance.get_global_position())
		"leavebuilding":
			_go_to_target(in_building.get_node("house_interior").get_node("Entrance").get_global_position())
		"read": 
			_got_to_object("bookshelf", "read")
		#"Eat": pass
		#"Sleep": pass
		"idle": 
			pass
		_:print("No such action")
	
	is_requesting_action = false
	agentActions.current_action = new_action

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
	ServerConnection.post_message(text,speechLabel)
	
