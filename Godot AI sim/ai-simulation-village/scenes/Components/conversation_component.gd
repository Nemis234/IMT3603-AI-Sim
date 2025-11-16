extends Node
class_name ConversationComponent

var agent: Agent

func _ready():
	agent = get_parent() as CharacterBody2D

func start_convo_pathfinding(convo_target:Agent,go_to_agent:Callable):
	convo_target.new_action = "idle"
	convo_target.current_action = "idle"
	convo_target.queued_action = ["idle"]
	for _x in range(3) :
		convo_target.queued_action.append("idle") 
	
	go_to_agent.call(convo_target,"conversation")
