extends CanvasLayer

@onready var panel = $Control/Panel
@onready var container = $Control/Panel/VBoxContainer
@onready var label = $Control/Panel/VBoxContainer/Label
@onready var button_container = $Control/Panel/VBoxContainer/HBoxContainer

signal choice_made(choice_text: String)

func _ready():
	hide_menu()

func show_menu(question: String, choices: Array):
	label.text = question
	
	# Clear old buttons
	for child in button_container.get_children():
		child.queue_free()
	
	# Add new buttons dynamically for each choice
	for choice_text in choices:
		var btn = Button.new()
		btn.text = choice_text
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", _on_choice_pressed.bind(choice_text))
		button_container.add_child(btn)
	
	# Wait for layout to update
	await get_tree().process_frame
	await get_tree().process_frame  # extra frame ensures layout is recalculated
	
	# Force VBoxContainer to recalc
	container.queue_sort()
	
	# Get correct size
	var container_size = container.get_combined_minimum_size()
	panel.size = container_size
	panel.position = Vector2(get_viewport().size) / 2 - panel.size / 2
	
	visible = true

func hide_menu():
	visible = false

func _on_choice_pressed(choice_text: String):
	# Signal for further interaction logic
	emit_signal("choice_made", choice_text)
	hide_menu()
