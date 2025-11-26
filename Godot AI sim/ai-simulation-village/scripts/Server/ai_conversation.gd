extends Node

## The number of messages sent in the whole conversation. [br]
## This includes the initial message at least one response, 
## ie. setting this to less than 2 does nothing
var numb_chat_messages = 4:
	set(value):
		if value < 2:
			value = 2
		numb_chat_messages = value

var timer = Timer.new()
var pause_messages: bool = false:
	set(value):
		if value:
			timer.start()
		pause_messages = value

func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = 6
	timer.timeout.connect(func():
		pause_messages=false)
	
	add_child(timer)


func _wait_on_timer():
	while pause_messages:
		await get_tree().process_frame


func init_agent2agent_conversation(agent1:String, agent2:String, output1:SpeechBubble,output2:SpeechBubble):
	## The starting message
	var initial_message = "You are starting a whole new conversation with " + agent2 + ". What do you say to them?"

	pause_messages = true
	var response = await ServerConnection.post_message(agent1,initial_message,output1.get_label(),"chat/start_ai_chat",agent2)
	await _wait_on_timer()

	var last_agent = agent1
	var next_agent = agent2
	
	var last_output = output1
	var next_output = output2
	for x in range(numb_chat_messages-2):
		pause_messages = true
		last_output.visible = false
		next_output.visible = true
		
		last_output.get_label().text = ""
		
		response = await ServerConnection.post_message(next_agent,response,next_output.get_label(),"chat",last_agent)
		
		# Switches the agents
		var temp_agent = next_agent
		next_agent = last_agent
		last_agent = temp_agent
		
		var temp_output = next_output
		next_output = last_output
		last_output = temp_output
		
		if timer.is_stopped():
			continue
		
		await timer.timeout
	
	last_output.visible = false
	next_output.visible = true
	
	response = await ServerConnection.post_message(next_agent,response,next_output.get_label(),"chat",last_agent)
	
	await ServerConnection.post_message(last_agent,response,last_output.get_label(),"set_memory",next_agent)
	
	
