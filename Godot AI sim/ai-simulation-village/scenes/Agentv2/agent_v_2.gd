class_name Agent
extends CharacterBody2D

@onready var agent_interact_area: Area2D = $InteractArea
@onready var objectDetectionArea: Area2D = $ObjectDetection

@export var movementAnimation: WalkingAnimationComponent
@export var pathfindingComponent: PathfindingComponent
@export var randomVectorOnNavigationLayer: RandomVectorOnNavigationLayerComponent
@export var actionList: AgentActionListComponent
@export var interactionComponent: AgentActionInteractionComponent
@export var agentStats: AgentStatComponent

@onready var speechBubble = $SpeechBubble
@onready var speechLabel = $SpeechBubble/Control/PanelContainer/ScrollContainer/MarginContainer/Label

#Agent identifications
@export var agentName: String

#Agents house/building related
@export var house: Node2D
@export var agentBed: Node2D
var house_entrance
@onready var in_building: Node2D = house #Stores the building the agent is in.

#Agents action related
var agent_action_done: bool = true
var new_action
var current_action # Stores the agents current action 
var duration_action
var queued_action = ""
var is_requesting_action:bool = false #Helps with overrequesting actions
var in_dialogue: bool = false #To check if agent in dialogue
@onready var command_stream = $AICommand


func _ready() -> void:
	house_entrance = house.get_node("house_exterior").get_node("Entrance")
	
	agent_interact_area.body_entered.connect(_on_interact_area_entered)
	agent_interact_area.body_exited.connect(_on_interact_area_exited)

	#Add their designated bed
	actionList.interactable_objects[agentBed] = {
	"building": house, 
	"position": agentBed.get_node("Marker2D").get_global_position(), 
	"name": agentBed.name
	}
	
func _process(_delta: float) -> void:
	if agent_action_done:
		await interactionComponent._delay_agent_action(100)
		new_agent_action()

func _physics_process(delta: float) -> void:
	if in_dialogue:
		movementAnimation.update_animation(Vector2.ZERO)
		return
	
	#if duration_action > 0:
		#duration_action -= 2 * (Global.realSecondsPerIngameDay / 1440)
	#print(duration_action)
	pathfindingComponent.move_along_path(delta)
	movementAnimation.update_animation(velocity)
	

#Used upon reaching target destination
func _on_pathfinding_component_target_reached() -> void:
	await interactionComponent._delay_agent_action(1)
	match current_action:
		"wander":
			agent_action_done = true
		"gohome":
				interactionComponent._interact_with_object("","entrance")
		"leavebuilding":
				interactionComponent._interact_with_object("","entrance")
		"read": 
			await interactionComponent._interact_with_object("interactable","bookshelf")
		"eat":
			await interactionComponent._interact_with_object("interactable","fridge")
		"sleep":
			await interactionComponent._interact_with_object("interactable", "bed")
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
		
	if queued_action == "":
		#var action_details = await actionList.prompt_new_action(house,in_building,agentStats.stats,command_stream) # Enable this for AI controlling
		#new_action = action_details["action"]
		#duration_action = action_details["duration"] #Expected Duration to perform action in minutes
		
		new_action = actionList.pick_random_action(house, in_building, agentStats.stats) #Enable this to pick randomly without AI
		duration_action = clamp(randf_range(100,480),100,480)
	else:
		new_action = queued_action
		queued_action = ""
	
	match new_action:
		"wander":
			if !in_building:
				pathfindingComponent._go_to_target(randomVectorOnNavigationLayer.get_random_target_main_map())
			elif in_building:
				pathfindingComponent._go_to_target(randomVectorOnNavigationLayer.get_random_target_in_building(in_building))
		"gohome":
			pathfindingComponent._go_to_target(house_entrance.get_global_position())
		"leavebuilding":
			pathfindingComponent._go_to_target(in_building.get_node("house_interior").get_node("Entrance").get_global_position())
		"read": 
			pathfindingComponent._got_to_object("bookshelf", "read")
		"eat":
			pathfindingComponent._got_to_object("fridge", "eat")
		"sleep":
			#TODO will agents have a designated bed?
			pathfindingComponent._got_to_object("bed", "sleep")
		"idle": 
			pass
		_:print("No such action")
	
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


func _on_object_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("interactable") and not area.get_parent().is_in_group("Doors"):
		actionList.interactable_objects[area.get_parent()] = {
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
	
