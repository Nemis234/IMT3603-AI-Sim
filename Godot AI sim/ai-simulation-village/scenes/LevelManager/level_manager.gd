extends Node2D


@onready var player:Player = $Adam

#Day and night cycle, related
@onready var dayNightCycle:Node2D = $DayNightCycle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting up signals connection/set global variables 
	for node in get_children():
		if node.is_in_group("Player"):
			#node.interact.connect(_change_state)
			node.end_convo.connect(_end_dialogue)
			node.get_node("ChatBox").chat_input.connect(_generate_dialogue)

		if node.is_in_group("Agent"):
			node.interactionComponent.interact.connect(_change_state)
			Global.agent_houses[node.agentName] = node.house #Register name and house

	for node in get_tree().get_nodes_in_group("interactable"):
		node.connect("request_popup", _on_request_popup)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_physics_process(_delta: float) -> void:
	#print(player.curr_interactable)
	pass
	
func _process(delta: float) -> void:
	Global.time += delta / Global.realSecondsPerIngameDay
	#Global.time = fmod(Global.time, 1.0)
	var time_per_day = fmod(Global.time, 1.0)
	_process_time(delta)
	dayNightCycle.setDayNightColor(time_per_day)

func _change_state(entity,interactable):
	#print("signal sent",interactable.is_in_group("house_int"))
	print(entity," interacts with: ", interactable)
	if interactable.is_in_group("house_ext"):
		var house = interactable.get_parent()
		entity.position = house.exit_area.get_global_position()
		
		if entity.is_in_group("Player"):
			dayNightCycle.hideDayNightFilter("hide")
		
		if entity.is_in_group("Agent"):
			entity.currentLocation = house.name 


	elif interactable.is_in_group("house_int"):
		print("Changing position")
		var house = interactable.get_parent()
		entity.position = house.door_area.get_global_position()
		
		if entity.is_in_group("Player"):
			dayNightCycle.hideDayNightFilter("unhide")
		
		if entity.is_in_group("Agent"):
			entity.currentLocation = "outside of " + house.name

	elif interactable.is_in_group("interactable"):
		interactable.change_state(entity)
	
	
		

#Tell the Agents to start a new action/check if they finished their action
#func _on_agent_timer_timeout() -> void:
	#for agents in get_tree().get_nodes_in_group("Agent"):
		#agents.new_agent_action()


func _generate_dialogue(text:String): #Dialogue should occur if player's curr interactable is an Agent
	if player.recipient_in_convo: 
		if player.recipient_in_convo.is_in_group("Agent"):
			player.recipient_in_convo.stream_speech(text)
	

#func to end dialogue with agent
func _end_dialogue(agent):
	var chatbox = player.get_node("ChatBox")
	chatbox.visible = false #Remove chat from screen
	chatbox.get_node("LineEdit").text = "" #Clear previous chatbox entry
	player.in_dialogue = false
	
	agent.hide_speech()
	
	agent.in_dialogue = false

	

	
##This functions is used to process ingame time.
func _process_time(delta) -> void:
	Global.totalMinutes = Global.time * 1440.0
	Global.minute = int(Global.totalMinutes) % 60
	Global.hour = int(Global.totalMinutes / 60) % 24
	Global.day = int(int(Global.totalMinutes / 60) / 24) + 1 
	
	if Global.hour >= 22 or Global.hour < 6:
		Global.partOfDay = "night"
	elif Global.hour >= 6 and Global.hour < 8:
		Global.partOfDay = "morning"
	elif Global.hour >= 8 and Global.hour < 12:
		Global.partOfDay = "noon"
	elif Global.hour >= 12 and Global.hour < 16:
		Global.partOfDay = "afternoon"
	else:
		Global.partOfDay = "evening"
	
	#print("In-game time: %02d:%02d" % [hour, minute])
	#print(partOfDay)
	

func _on_request_popup(question, choices):
	$PopupMenu.show_menu(question, choices)
	
