extends CanvasLayer

@onready var panel = $Control/Panel
@onready var container = $Control/Panel/VBoxContainer
@onready var item_container = $Control/Panel/VBoxContainer/ItemContainer
@onready var label = $Control/Panel/VBoxContainer/Label

func _ready():
	hide_menu()

func display_inventory(label_text: String, inventory: Array[Item]):
	label.text = label_text
	# Clear old items from inventory
	for item in item_container.get_children():
		item.queue_free()
	
	# Add new buttons dynamically for each item
	for item in inventory:
		var btn = Button.new()
		btn.flat = true
		btn.text = "%s x%d" % [item.name, item.quantity]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.connect("pressed", _on_choice_pressed.bind(item))
		item_container.add_child(btn)
	
	# Wait for layout to update
	await get_tree().process_frame
	await get_tree().process_frame  # extra frame ensures layout is recalculated
	
	# Force VBoxContainer to recalc
	container.queue_sort()
	
	# Get correct size
	var container_size = container.get_combined_minimum_size()
	panel.size = container_size
	panel.position = panel.size / 2
	
	visible = true

func hide_menu():
	visible = false

func _on_choice_pressed(item: Item):
	print("You selected: ", item.name)
	print("Description: ", item.description)
	print("Quantity: ", item.quantity)
	hide_menu()
