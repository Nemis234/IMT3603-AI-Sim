extends Control
signal chat_input(input)

var text_output:String = ""
@export var text_input : LineEdit


func _on_button_pressed() -> void:
	var text = text_input.text
	chat_input.emit(text)
