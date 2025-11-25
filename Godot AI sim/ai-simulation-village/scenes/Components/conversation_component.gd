extends Node
class_name ConversationComponent

var agent: Agent

func _ready():
	agent = get_parent() as CharacterBody2D

func start_convo_pathfinding(convo_target:Agent,go_to_agent:Callable):
	convo_target.pending_conversation = Agent.CONVO.pending 
	if go_to_agent.call(convo_target,"conversation"):
		convo_target.pending_conversation = Agent.CONVO.pending_same_location 


func start_conversation(convo_target:Agent):
	convo_target.pending_conversation = Agent.CONVO.in_progress
	agent.pending_conversation = Agent.CONVO.in_progress
	convo_target.show_speech()
	agent.show_speech()
	
	await AiConversation.init_agent2agent_conversation(agent.agentName,convo_target.agentName,
	agent.speechBubble.get_label(),
	convo_target.speechBubble.get_label()
	)
	
	convo_target.pending_conversation = Agent.CONVO.none
	agent.pending_conversation = Agent.CONVO.none
	agent.agent_action_done = true
	
	await get_tree().create_timer(5).timeout
	
	convo_target.hide_speech()
	agent.hide_speech()
