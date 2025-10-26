extends Control

@onready var chat1: Label = $VBoxContainer/ChatBubble1/Chat
@onready var chat2: Label = $VBoxContainer/ChatBubble2/Chat


func _on_button_pressed() -> void:
	AiConversation.init_agent2agent_conversation("John","Mei",chat1,chat2)
