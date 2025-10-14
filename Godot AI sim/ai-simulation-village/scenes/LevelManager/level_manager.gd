extends Node2D


@onready var player:Player = $Adam


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_children():
		if node.is_in_group("Player"):
			node.interact.connect(_change_state)
			node.end_convo.connect(_end_dialogue)
			node.get_node("ChatBox").chat_input.connect(_generate_dialogue)

		if node.is_in_group("Agent"):
			node.interact.connect(_change_state)
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_physics_process(delta: float) -> void:
	#print(player.curr_interactable)
	pass
	


func _change_state(entity,interactable):
	#print("signal sent",interactable.is_in_group("house_int"))
	print(entity," interacts with: ", interactable)
	if interactable.is_in_group("house_ext"):
		var house = interactable.get_parent()
		entity.position = house.exit_area.get_global_position()

	elif interactable.is_in_group("house_int"):
		print("Changing position")
		var house = interactable.get_parent()
		entity.position = house.door_area.get_global_position()

	elif interactable.is_in_group("interactable"):
		interactable.change_state()
	
	elif entity.is_in_group("Player") and interactable.is_in_group("Agent"): #If Player Engages chat with agent
		var agent: Agent = interactable
		
		player.get_node("ChatBox").visible = true
		player.in_dialogue = true
		agent.in_dialogue = true
		

		agent.agentActions.current_action = "Idle"
		agent.agentActions.agent_action_done = false

		

		

#Tell the Agents to start a new action/check if they finished their action
func _on_agent_timer_timeout() -> void:
	for agents in get_tree().get_nodes_in_group("Agent"):
		agents.new_agent_action()


func _generate_dialogue(text:String): #Dialogue should occur if player's curr interactable is an Agent
	if player.curr_interactable: 
		if player.curr_interactable.is_in_group("Agent"):
			player.curr_interactable.stream_speech(text)
	pass

#func to end dialogue with agent
func _end_dialogue(agent):
	var chatbox = player.get_node("ChatBox")
	chatbox.visible = false #Remove chat from screen
	chatbox.get_node("LineEdit").text = "" #Clear previous chatbox entry
	player.in_dialogue = false
	
	agent.hide_speech()
	agent.agentActions.agent_action_done = true
	agent.in_dialogue = false
