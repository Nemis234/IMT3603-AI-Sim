extends Node

var client : HTTPClient
var stream = false




# I initialise the request
func _ready() -> void:
	#connect_client()
	pass

func connect_client():
	var err = 0
	client = HTTPClient.new()
	err = client.connect_to_host("http://127.0.0.1",8000)
	assert(err==OK)
	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll()
		print("Connecting...")
		await get_tree().process_frame
	
	assert(client.get_status() == HTTPClient.STATUS_CONNECTED)

## Recicpiant is the AI agent that is being talked too. 
## Will be an ENUM with all available agents. 
## Requests a spesific agent using its url [code]"/chat/{recipiant}"[/code] [br]
## Participant is whoever is talking to the AI agent.
## Defaults to "user" [br]
func post_message(agentName:String,message:String, label_:Label, type:String ="chat", participant="user", recipiant:int=0):
	var err = 0
	var fields = {
		"agent":agentName,
		"time":str(Global.hour) + ":" + str(Global.minute),
		"message": message, 
		"participant": participant 
		}
	print(fields)
	var query_string = JSON.stringify(fields)
	var headers = [ #Not necessary
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
	client.poll()
	if client.get_status() == HTTPClient.STATUS_CONNECTION_ERROR:
		await connect_client()
	
	err = client.request(HTTPClient.METHOD_POST,"/"+type,headers,query_string)
	assert(err == OK)
	
	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		client.poll()
		print("Requesting...")
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
	print("Text: ", text)
	
