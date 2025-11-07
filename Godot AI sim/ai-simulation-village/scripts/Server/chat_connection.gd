extends Control
signal chat_input(input)

var text_output:String = ""
@export var text_input : LineEdit


func _on_button_pressed() -> void:
	var text = text_input.text
	chat_input.emit(text)


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_button_pressed()
