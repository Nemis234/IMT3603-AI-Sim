extends Node


const SERVER_URL = "http://127.0.0.1"
const SERVER_PORT = 8000


# I initialise the request
func _ready() -> void:
	#connect_client()
	pass

func connect_client() -> HTTPClient:
	var client
	var err = 0
	client = HTTPClient.new()
	err = client.connect_to_host(SERVER_URL,SERVER_PORT)
	assert(err==OK)
	print("Connecting...")
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		await get_tree().process_frame
	
	assert(client.get_status() == HTTPClient.STATUS_CONNECTED)
	
	return client


## Sends a request using the given client. [br]
## Output text is written to the label_, and is returned in full when complete. [br]
func send_request(label_:Label,client:HTTPClient,method:HTTPClient.Method,url:String,headers:PackedStringArray,query_string:String="")->String:
	client.poll()
	if client.get_status() == HTTPClient.STATUS_CONNECTION_ERROR:
		await connect_client()
	
	var status = client.get_status()
	var err = client.request(method,url,headers,query_string)
	assert(err == OK)
	
	print("Requesting to '",url,"'...")
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
			#print(rb.get_string_from_utf8())
	print("bytes got: ", rb.size())
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
	print(fields)
	var query_string = JSON.stringify(fields)
	var headers = [ #Not necessary
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
	var text = await send_request(label_,client,HTTPClient.METHOD_POST,"/"+type,headers,query_string)
	
	return text
	

#New creating sepearte post method for actions (passing entire dict of agent details so it becomes easier to add more details)
func post_action(agent_details:Dictionary, label_:Label):
	var client = await connect_client()
	agent_details["time"] = "Day "+str(Global.day)+" "+agent_details["time"]
	
	print(agent_details)
	
	
	var query_string = JSON.stringify(agent_details)
	var headers = [ #Not necessary
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
	var text = await send_request(label_,client,HTTPClient.METHOD_POST,"/action",headers,query_string)
	print(text)
	
