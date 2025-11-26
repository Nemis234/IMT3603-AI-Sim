extends Control
class_name SpeechBubble

@onready var label: Label = %Label
@onready var name_label: Label = %NameLabel

func get_label()->Label:
	return label

func get_name_label()->Label:
	return name_label
