extends Control

@onready var chat1: Label = $VBoxContainer/ChatBubble1/Chat
@onready var chat2: Label = $VBoxContainer/ChatBubble2/Chat

@onready var name_label1: Label = $VBoxContainer/SpeechBubble/PanelContainer/VBoxContainer/NameLabel
@onready var name_label2: Label = $VBoxContainer/SpeechBubble2/PanelContainer/VBoxContainer/NameLabel

@onready var speech_bubble: SpeechBubble = $VBoxContainer/SpeechBubble
@onready var speech_bubble_2: SpeechBubble = $VBoxContainer/SpeechBubble2


var agent1 = "John"
var agent2 = "Mei"

func _ready() -> void:
	name_label1.text = agent1 + ":"
	name_label2.text = agent2 + ":"

func _on_button_pressed() -> void:
	AiConversation.init_agent2agent_conversation(agent1,agent2,speech_bubble,speech_bubble_2)


func _on_button_2_pressed() -> void:
	var temp = agent1
	agent1 = agent2
	agent2 = temp
	
	_ready()
