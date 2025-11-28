extends Node


const SERVER_URL = "http://127.0.0.1"
const SERVER_PORT = 8000

## Initialises a new [HTTPClient]
func connect_client() -> HTTPClient:
	var client
	var err = 0
	client = HTTPClient.new()
	err = client.connect_to_host(SERVER_URL,SERVER_PORT)
	assert(err==OK)
	
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		await get_tree().process_frame
	
	assert(client.get_status() == HTTPClient.STATUS_CONNECTED)
	
	return client


## Sends a request to the url using the given client. [br]
## Output text is written to the label_ if provided, and is returned in a string when complete. [br]
func send_request(client:HTTPClient,url:String,
	query_string:String="",
	label_:Label=Label.new(),
	method:HTTPClient.Method=HTTPClient.METHOD_POST,
	headers:PackedStringArray=[]
	)->String:
	
	if not headers:
		headers = [ #Not necessary
			"User-Agent: AI-village/1.0 (Godot)",
			"Accept: */*"
		]
	
	client.poll()
	if client.get_status() == HTTPClient.STATUS_CONNECTION_ERROR:
		client = await connect_client()
	
	var _status = client.get_status()
	var err = client.request(method,url,headers,query_string)
	assert(err == OK)
	
	
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		client.poll()
		await get_tree().process_frame
	
	assert(client.get_status() == HTTPClient.STATUS_BODY or client.get_status() == HTTPClient.STATUS_CONNECTED)
	
	var rb = PackedByteArray() # Array that will hold the data.
	while client.get_status() == HTTPClient.STATUS_BODY:
		# While there is body left to be read
		client.poll()
		# Get a chunk.
		var chunk = client.read_response_body_chunk()
		if chunk.size() == 0:
			await get_tree().process_frame
		else:
			rb = rb + chunk # Append to read buffer.
			label_.text = rb.get_string_from_utf8()
			
	
	var text = rb.get_string_from_utf8()
	return text


## Participant is whoever is talking to the AI agent.
## Defaults to "user" [br]
func post_message(agentName:String,message:String, label_:Label, type:String="chat", participant="user")->String:
	var client := await connect_client()

	var h = Global.hour
	var hour = "0"+ str(h) if h < 10 else str(h)
	var m = Global.minute
	var minute = "0"+str(m) if m < 10 else str(m)

	var fields = {
		"agent":agentName,
		"time": "Day "+str(Global.day)+" "+ hour + ":" + minute ,
		"message": message, 
		"participant": participant 
		}
	
	var query_string = JSON.stringify(fields)
	
	var text = await send_request(client,"/"+type,query_string,label_)
	
	return text


#New creating seperate post method for actions (passing entire dict of agent details so it becomes easier to add more details)
func post_action(agent_details:Dictionary, label_:Label):
	var client = await connect_client()
	agent_details["time"] = "Day "+str(Global.day)+" "+agent_details["time"]
	
	
	
	var query_string = JSON.stringify(agent_details)
	
	var _text = await send_request(client,"/action",query_string,label_)
	
	return _text
	
	

#Sends a request to decrement the recency of all existing memories for a given agent
func update_memory_recency(agentName:String) -> void:
	var client := await connect_client()
	
	var query_string = JSON.stringify(agentName)
	
	var _text = await send_request(client,"/update_recency",query_string)
	
# For sending requests to agents to reflect on all relevant events
func get_reflection(agentName:String) -> void:
	var client := await connect_client()

	var query_string = JSON.stringify(agentName)
	
	var _text = await send_request(client,"/get_reflections",query_string)

#To get the save slot number. Modes can be "create" to get/obtain the slot or "delete" to delete the collections associated with that slot
func send_save_slot(slot:int,mode="create"):
	var client := await connect_client()

	var query_string = JSON.stringify(str(slot))
	
	if mode=="create":
		var _text = await send_request(client,"/get_save_slot",query_string)
	elif mode == "delete":
		var _text = await send_request(client,"/delete_save_slot",query_string)
	else:
		assert(false,"Invalid mode. Mode can only be 'create' or 'delete'")
