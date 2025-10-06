extends Node


@export var label_: Label
@export var text_input : LineEdit

func _on_button_pressed() -> void:
	var text = text_input.text
	ServerConnection.post_message(text,label_)
