extends Control

@onready var chat1: Label = $VBoxContainer/ChatBubble1/Chat
@onready var chat2: Label = $VBoxContainer/ChatBubble2/Chat
@onready var agent_1: Label = $VBoxContainer/ChatBubble1/Agent_1
@onready var agent_2: Label = $VBoxContainer/ChatBubble2/Agent_2



var agent1 = "John"
var agent2 = "Mei"

func _ready() -> void:
	agent_1.text = agent1 + ":"
	agent_2.text = agent2 + ":"

func _on_button_pressed() -> void:
	AiConversation.init_agent2agent_conversation(agent1,agent2,chat1,chat2)


func _on_button_2_pressed() -> void:
	var temp = agent1
	agent1 = agent2
	agent2 = temp
	
	_ready()
