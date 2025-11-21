extends Node2D

var save_path = Global.selected_save

@onready var player:Player = $Adam
@onready var player_inv_ui = $PlayerInventoryUi
@onready var object_inv_ui = $ObjectInventoryUi

# Variables for tracking inventory context
var inventory_item: Item = null
var source_invnetory: Node = null

#Day and night cycle, related
@onready var dayNightCycle:Node2D = $DayNightCycle
@onready var agentTimer: Timer = $AgentTimer
var agent_list: Dictionary = {} #To store list of agents
var all_interactables: Dictionary = {} # Stores list of all intercatables
var id = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting up signals connection/set global variables 
	#agentTimer.timeout.connect(_on_agent_timer_timeout)
	# Pass PopupMenu reference to both inventory UIs
	player_inv_ui.set_popup_menu($PopupMenu)
	object_inv_ui.set_popup_menu($PopupMenu)
	$PopupMenu.connect("choice_made", _on_choice_made)
	player_inv_ui.connect("show_info", _on_request_popup)
	player.connect("open_inventory", player_inv_ui.display_inventory)
	player.connect("close_inventory", player_inv_ui.hide_menu)
	object_inv_ui.connect("show_info", _on_request_popup)
	object_inv_ui.connect("exit_pressed", _exit_object_inventory)
	
	
	for node in get_children():
		if node.is_in_group("Player"):
			#node.interact.connect(_change_state)
			node.end_convo.connect(_end_dialogue)
			node.get_node("ChatBox").chat_input.connect(_generate_dialogue)

		if node.is_in_group("Agent"):
			node.interactionComponent.interact.connect(_change_state)
			Global.agent_houses[str(node.agentName)+"'s House"] = node.house #Register name and house
			agent_list[node.agentName] = node

	for node in get_tree().get_nodes_in_group("interactable"):
		# check if interactable has signal before connecting
		
		
		if node.has_signal("open_inventory"):
			node.connect("open_inventory", object_inv_ui.display_inventory)
			node.fill_fridge()
		if node.has_signal("request_popup"):
			node.connect("request_popup", _on_request_popup)
		
		if node.has_signal("save"):
			node.connect("save", _save_game)
		
		
		all_interactables[id] = node #Add interactable to array of all
		id+=1

		#print(all_interactables)
			
	
	#Load basic save
	load_save()


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

func _change_state(entity,interactable_):
	if interactable_.is_in_group("house_ext"):
		var house = interactable_.get_parent()
		entity.position = house.exit_area.get_global_position()
		
		if entity.is_in_group("Player"):
			dayNightCycle.hideDayNightFilter("hide")
		
		if entity.is_in_group("Agent"):
			entity.currentLocation ={"location": str(house.name) , "sub_location": str(house.name) +' exit'} 

	elif interactable_.is_in_group("house_int"):
		var house = interactable_.get_parent()
		entity.position = house.door_area.get_global_position()
		
		if entity.is_in_group("Player"):
			dayNightCycle.hideDayNightFilter("unhide")
		
		if entity.is_in_group("Agent"):
			entity.currentLocation = {"location": "outside" , "sub_location": "outside"} 

	elif interactable_.is_in_group("interactable"):
		if entity.is_in_group("Agent"):
			entity.currentLocation["sub_location"] = str(interactable_.name)

		interactable_.change_state(entity)
	
	
		

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
func _process_time(_delta) -> void:
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

################################################

## Relating to pop_menu and chices for certain interactables ##
func _on_request_popup(info_text, choices, item: Item = null, source: Node = null):
	player.in_interaction = true
	inventory_item = item
	source_invnetory = source
	$PopupMenu.show_menu(info_text, choices)

func _exit_object_inventory():
	object_inv_ui.hide_menu()
	player.in_interaction = false
	inventory_item = null
	
func _on_choice_made(choice_text:String):
	# Handle inventory-related choices
	if choice_text == "OK" and !object_inv_ui.is_open:
		player.in_interaction = false
	elif choice_text == "Take":
		_handle_take_item()
	elif choice_text == "Use":
		_handle_use_item(source_invnetory)
	elif choice_text == "Store":
		_handle_store_item()
	elif player.curr_interactable and player.curr_interactable.has_method("on_choice_made"):
		player.curr_interactable.on_choice_made(choice_text)
		
	
func _handle_take_item():
	if !inventory_item:
		print("No item selected")
		return
	elif !player.curr_interactable:
		print("No interactable object")
		return
	player.curr_interactable.inventory.remove_item(inventory_item.name, 1)
	player.inventory.add_item(inventory_item.name, 1)
	# print for testing can be removed
	print("Took 1x %s from %s" % [inventory_item.name, player.curr_interactable.name])
	_refrech_inventory_ui()
	_refrech_object_ui()
	inventory_item = null
	source_invnetory = null
	
func _handle_use_item(source: Node):
	if !source:
		player.curr_interactable.inventory.remove_item(inventory_item.name, 1)
		_refrech_object_ui()
		# print for testing can be removed
		print("Used 1x %s from %s" % [inventory_item.name, player.curr_interactable.name])
	else:
		player.inventory.remove_item(inventory_item.name, 1)
		_refrech_inventory_ui()
		# print for testing can be removed
		print("Used 1x %s from %s" % [inventory_item.name, "player inventory"])
	#TODO add further use logic for items
	if !object_inv_ui.is_open:
		player.in_interaction = false
	inventory_item = null
	source_invnetory = null
	
func _handle_store_item():
	if !inventory_item:
		print("No item selected")
		return
	elif !player.curr_interactable:
		print("No interactable object")
		return
	player.inventory.remove_item(inventory_item.name, 1)
	player.curr_interactable.inventory.add_item(inventory_item.name, 1)
	# print for testing can be removed
	print("Stored 1x %s in %s" % [inventory_item.name, player.curr_interactable.name])
	_refrech_inventory_ui()
	_refrech_object_ui()
	inventory_item = null
	source_invnetory = null

func _refrech_inventory_ui():
	player_inv_ui.display_inventory(
		"Your current inventory",
		player.inventory.items,
		player
	)

func _refrech_object_ui():
	object_inv_ui.display_inventory(
		player.curr_interactable.name + " inventory",
		player.curr_interactable.inventory.items
	)

###############################################################

### Time out to update recency of all memories ###
func _on_agent_timer_timeout():
	for agent in agent_list.keys():
		ServerConnection.update_memory_recency(agent) #Update memory recency

###################################################


### Time out to get refelections #####
func _on_refelection_timer_timeout() -> void:
	for agent in agent_list.keys():
		ServerConnection.get_reflection(agent) #Get reflections for each agent

###################################################

##### Saving and Loading ######
func _save_game():
	var save_data = {
		"time": Global.time,
		"player_details": player.get_player_details(),
		"agent_details": Dictionary(),
		"object_states": Dictionary() #Saves certain object states
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)

	for node in agent_list.values():
		save_data["agent_details"][str(node.agentName)] = node.get_agent_details() # Ex: {"agent1": {details}, "agent2": {details} }
	
	for node_id in all_interactables.keys():
		var object = all_interactables[node_id]
		save_data["object_states"][node_id] = {}
		if object.has_node("Inventory"):
			save_data["object_states"][node_id]["inventory"] = object.inventory.get_inventory()
		

	
	file.store_var(save_data)
	file.close()

func load_save():
	if not FileAccess.file_exists(save_path):
		return

	print("Loading save")
	var file = FileAccess.open(save_path, FileAccess.READ)
	var data = file.get_var()
	file.close()

	Global.time = data["time"]
	player.set_player_details(data["player_details"])
	
	for node in agent_list.values():
		if str(node.agentName) in data["agent_details"]:
			node.set_agent_details(data["agent_details"][str(node.agentName)])
	
	for node_id in all_interactables.keys():
		if node_id in data["object_states"]:
			var object = all_interactables[node_id] #interctabel node
			if object.has_node("Inventory"):
				var inventory_details = data["object_states"][node_id]["inventory"]
				object.inventory.set_inventory(inventory_details)


func _on_auto_save_timer_timeout() -> void:
	print("Game has been auto-saved")
	_save_game()

##################################################

##Helper thta hashes node based on path
