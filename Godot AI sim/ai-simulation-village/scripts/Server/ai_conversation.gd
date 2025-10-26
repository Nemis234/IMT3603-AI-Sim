extends Node

var timer = Timer.new()
var pause_messages: bool = false:
	set(value):
		if value:
			timer.start()
			print("Timer started")
		pause_messages = value

func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = 4
	timer.timeout.connect(func():
		print("timeout")
		pause_messages=false)
	
	add_child(timer)


func _wait_on_timer():
	while pause_messages:
		await get_tree().process_frame


func init_agent2agent_conversation(agent1:String, agent2:String, output1:Label,output2:Label):
	## The starting message
	var initial_message = "You are starting a conversation with " + agent2 + ". What do you say to them?"
	
	# The respones from each agent
	var response_from_1 
	var response_from_2
	
	
	pause_messages = true
	response_from_1 = await ServerConnection.post_message(agent1,initial_message,output1,"chat/start_ai_chat",agent2)
	await _wait_on_timer()
	
	pause_messages = true
	response_from_2 = await ServerConnection.post_message(agent2,response_from_1,output2,"chat",agent1)
	await _wait_on_timer()
	
	response_from_1 = await ServerConnection.post_message(agent1,response_from_2,output1,"chat",agent2)
	
	await ServerConnection.post_message(agent2,response_from_2,output2,"set_memory",agent1)
	
	
