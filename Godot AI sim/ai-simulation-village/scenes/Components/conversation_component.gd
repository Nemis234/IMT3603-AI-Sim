extends Node
class_name ConversationComponent

var agent: Agent

func _ready():
	agent = get_parent() as CharacterBody2D

func start_convo_pathfinding(convo_target:Agent,go_to_agent:Callable):
	convo_target.pending_conversation = Agent.CONVO.pending 
	agent.pending_conversation = Agent.CONVO.pending_orginial_agent
	if go_to_agent.call(convo_target,"conversation"):
		convo_target.pending_conversation = Agent.CONVO.pending_same_location 
		agent.pathfindingComponent.navigationNode.avoidance_enabled = false
		convo_target.pathfindingComponent.navigationNode.avoidance_enabled = false


func start_conversation(convo_target:Agent):
	convo_target.pending_conversation = Agent.CONVO.in_progress
	agent.pending_conversation = Agent.CONVO.in_progress
	agent.show_speech()
	
	await AiConversation.init_agent2agent_conversation(agent.agentName,convo_target.agentName,
	agent.speechBubble,
	convo_target.speechBubble
	)
	
	
	await get_tree().create_timer(5).timeout
	
	convo_target.pending_conversation = Agent.CONVO.none
	agent.pending_conversation = Agent.CONVO.none
	agent.agent_action_done = true
	
	agent.pathfindingComponent.navigationNode.avoidance_enabled = true
	convo_target.pathfindingComponent.navigationNode.avoidance_enabled = true
	
	convo_target.hide_speech()
	agent.hide_speech()
