extends Node

@export var text_input : LineEdit
@export var label_ : Label

func _on_button_pressed() -> void:
	var text = text_input.text
	ServerConnection.post_message(text,label_)
	
