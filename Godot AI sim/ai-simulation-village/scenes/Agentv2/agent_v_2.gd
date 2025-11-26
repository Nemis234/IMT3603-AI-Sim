class_name Agent
extends CharacterBody2D


@onready var agent_interact_area: Area2D = $InteractArea
var on_mouse: bool = true # To see if the mouse is on the agent
var player_in_area: bool = false # Toggle to cehck if player is in its interact area
#@onready var player: Player = get_tree().root.get_node("LevelManager/Adam")
@onready var player: Player = get_tree().get_root().find_child("Adam", true, false) # searches for the node recursively

@onready var objectDetectionArea: Area2D = $ObjectDetection

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var actionList: AgentActionListComponent
@export var interactionComponent: AgentActionInteractionComponent
@export var agentStats: AgentStatComponent
@export var conversation_component: ConversationComponent

@onready var speechBubble = $SpeechBubble
@onready var speechLabel = $SpeechBubble/PanelContainer/MarginContainer/Label

#Agent identifications
@export var agentName: String

#Agents house/building related
@export var house: Node2D
@export var agentBed: Node2D
var house_entrance
@export var in_building: Node2D = null #house #Stores the building the agent is in.
@onready var currentLocation: Dictionary = {"location": str(house.name), "sub_location": str(agentBed.name)} 

#Agent Work related
@export var workPlace: Node2D
@export var workObject: Node2D

#Agents action related
enum CONVO{none,pending_orginial_agent,pending,pending_same_location,in_progress}
var pending_conversation: CONVO = CONVO.none

var agent_action_done: bool = true
var new_action
var current_action # Stores the agents current action 
var duration_action = 1 #To store the duration of agent's current action
var queued_action: = []
var is_requesting_action:bool = false #Helps with overrequesting actions
var in_dialogue: bool = false #To check if agent in dialogue
var visiting_building = "" #Used for action such as visit "which agent to visit?"
var conversation_partner = ""

@export var character = "steve"
@onready var command_stream = $AICommand


func _ready() -> void:
	house_entrance = house.house_exterior.get_node("Entrance")
	
	agent_interact_area.body_entered.connect(_on_interact_area_entered)
	agent_interact_area.body_exited.connect(_on_interact_area_exited)
	agent_interact_area.mouse_entered.connect(_on_mouse_entered)
	agent_interact_area.mouse_exited.connect(_on_mouse_exited)
	
	agent_interact_area.input_event.connect(_on_area_input_event.bind(player))

	#Add their designated bed
	actionList.interactable_objects[agentBed] = {
	"building": house, 
	"position": agentBed.get_node("Marker2D").get_global_position(), 
	"name": "myownbed"
	}
	
	#Add their workobject
	actionList.interactable_objects[workObject] = {
	"building": workPlace, 
	"position": workObject.get_node("Marker2D").get_global_position(), 
	"name": "work"
	}
	
	speechBubble.get_name_label().text = agentName

	
func _process(_delta: float) -> void:
	if agent_action_done and not self.in_dialogue:
		await interactionComponent._delay_agent_action(1)
		new_agent_action()
	
	

	
func _physics_process(delta: float) -> void:
	if in_dialogue:
		movementAnimation.update_animation(Vector2.ZERO)
		return
	for index in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		if collision.get_collider().is_in_group("Player"):
			velocity = collision.get_normal() * collision.get_collider_velocity().length()
	
	pathfindingComponent.move_along_path(delta)
	movementAnimation.update_animation(velocity)
	
	move_and_slide()

#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	await interactionComponent._delay_agent_action(1)
	
	match current_action:
		"wander":
			agent_action_done = true
		"gohome", "leavebuilding", "visit":
				interactionComponent._interact_with_object("","entrance")
		"read": 
			await interactionComponent._interact_with_object("interactable","bookshelf")
		"eat":
			await interactionComponent._interact_with_object("interactable","fridge")
		"sleep":
			await interactionComponent._interact_with_object("interactable", "bed")
		"work":
			await interactionComponent._interact_with_object("interactable", workObject.name.to_lower())
		"conversation":
			conversation_component.start_conversation(Global.agent_nodes[conversation_partner])
		_:
			pass
		

##Set a new action for agent. Actions can either be picked random or by an AI Model (Gemini).
##To switch between set-type, toggle between the commented "new_action = ..."
##partOfDay is to check for available actions
func new_agent_action():
	await interactionComponent._delay_agent_action(1)
	if !agent_action_done or is_requesting_action:
		return
	
	is_requesting_action = true
	agentStats.hide_progress_bar()
	
	if pending_conversation != CONVO.none and pending_conversation != CONVO.pending_orginial_agent:
		if pending_conversation == CONVO.pending:
			new_action = "wander"
		elif pending_conversation == CONVO.pending_same_location:
			new_action = "idle"
		elif pending_conversation == CONVO.in_progress:
			new_action = "idle"
	elif queued_action.is_empty():
		var action_details = await actionList.prompt_new_action(house,in_building,agentStats.stats,command_stream) # Enable this for AI controlling
		new_action = action_details["action"]
		duration_action = action_details["duration"] #Expected Duration to perform action in minutes
		visiting_building = str(action_details["visiting"]) #Get the name of the building/house the agents wants to visit. This will be "" if "visit" is not chosen as the current action
		conversation_partner = str(action_details["conversationPartner"])
		##new_action = actionList.pick_random_action(house, in_building, agentStats.stats) #Enable this to pick randomly without AI
		#new_action = "conversation"
		
		#new_action = ["visit","conversation"].pick_random()
		#
		#duration_action = clamp(randf_range(50,100),50,100)
		#if new_action in ["visit"]:
			#var visitList:Array = Global.agent_houses.keys().duplicate()
			#visitList.erase(house)
			#visiting_building = visitList.pick_random()
		#if new_action in ["conversation"]:
			#var convoList = Global.agent_nodes.keys().duplicate()
			#convoList.erase(agentName)
			#conversation_partner = convoList.pick_random()
	else:
		new_action = queued_action.pop_front()
	
	print(agentName, " is taking the action: ", new_action)
	
	match new_action:
		"wander":
			if !in_building:
				pathfindingComponent._go_to_target(randomVectorOnNavigationLayer.get_random_target_main_map())
			elif in_building:
				pathfindingComponent._go_to_target(randomVectorOnNavigationLayer.get_random_target_in_building(in_building))
		"gohome":
			pathfindingComponent._go_to_target(house_entrance.get_global_position(), new_action)
		"leavebuilding":
			pathfindingComponent._go_to_target(in_building.house_interior.get_node("Entrance").get_global_position())
		"visit":
			pathfindingComponent._go_to_target(
				Global.agent_houses[visiting_building].house_exterior.get_node("Entrance").get_global_position(),
				new_action,
				visiting_building
				)
		"conversation":
			var convo_target:Agent = Global.agent_nodes[conversation_partner]
			
			if pending_conversation == CONVO.none:
				if not convo_target.pending_conversation == CONVO.none:
					queued_action.push_front("idle")
					agent_action_done = true
					return
			
			conversation_component.start_convo_pathfinding(convo_target,pathfindingComponent.go_to_agent)
		"idle":
			agent_action_done = false
			await get_tree().create_timer(5).timeout
			agent_action_done = true
			
		_: pathfindingComponent._got_to_object(new_action) # Agent will go to object, depending on action
	
	is_requesting_action = false
	current_action = new_action


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


## Adds object to memory, also deletes and re-inserts if object exists.
## Reinsertion is needed for agents to use the recently added object.
func _on_object_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("interactable") and not area.get_parent().is_in_group("Doors"):
		if !(area.get_parent() == agentBed or area.get_parent() == workObject):
			
			if actionList.interactable_objects.has(area.get_parent()):
				actionList.interactable_objects.erase(area.get_parent())
			
			actionList.interactable_objects[area.get_parent()] = {
				"building": in_building, 
				"position": area.get_parent().get_node("Marker2D").get_global_position(), 
				"name": area.get_parent().name
				}
		
func _on_interact_area_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true


func _on_interact_area_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false

func _on_mouse_entered():
	agent_interact_area.modulate = Color(1, 1, 0.6) # highlight
	on_mouse = true


func _on_mouse_exited():
	agent_interact_area.modulate = Color(1, 1, 1) # remove highlight
	on_mouse = false


# On right click initiate chat with agents. Requires Interacting entity (in this case only player to be passed)
func _on_area_input_event(_viewport, event, _shape_idx, entity:Player):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and player_in_area:
		player.get_node("ChatBox").visible = true
		player.in_dialogue = true
		self.in_dialogue = true
		player.recipient_in_convo = self
		
		#Make agent face player
		movementAnimation.set_facing(entity.get_opposite_direction())
		movementAnimation.update_animation(-entity.player_direction)
		

func hide_speech():
	speechBubble.visible = false
	speechBubble.get_label().text = ""

func show_speech():
	speechBubble.visible = true

func stream_speech(text:String):
	show_speech()
	ServerConnection.post_message(agentName,text,speechBubble.get_label())
	
#Getter to retrieve agent details
func get_agent_details()-> Dictionary:
	return {
		"character": character,
		"current_location": currentLocation,
		"position": self.position,
		"movementAnimation": movementAnimation.get_path(),
		"pathfindingComponent": pathfindingComponent.get_path(),
		"in_building": in_building.get_path() if in_building else null,
		"visiting_building": visiting_building,
		"conversation_partner":conversation_partner,
		"stats": agentStats.stats,
		#"in_dialogue": in_dialogue,
		#"agent_action_done": agent_action_done,
		"current_action": current_action,
		"is_requesting_action":  is_requesting_action,
		"queued_action": queued_action
	}

#Setter to set agent details (While loading a save)
func set_agent_details(details:Dictionary) -> void:
	character = details["character"]
	currentLocation = details["current_location"]	

	if details["in_building"] != null:
		in_building = get_node(details["in_building"])
	else:
		in_building = null

	self.position = details["position"]
	
	movementAnimation = get_node(details["movementAnimation"])
	pathfindingComponent = get_node(details["pathfindingComponent"])
	visiting_building = details["visiting_building"]	
	agentStats.stats = details["stats"]
	queued_action = details["queued_action"]	
	conversation_partner = details["conversation_partner"]
	
	#Set queued action to the current action that was being performed in the last save
	current_action = details["current_action"]
	queued_action.append(current_action)
	agent_action_done = true #set action done to true so that upon loading, agent can continue the last action
	
	#is_requesting_action = details["is_requesting_action"]
	#queued_action = details["queued_action"]

	print("Set details for agent: " + str(agentName))
	print(details)
