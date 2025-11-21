extends CanvasLayer

@onready var panel = $Control/Panel
@onready var container = $Control/Panel/VBoxContainer
@onready var item_container = $Control/Panel/VBoxContainer/ItemContainer
@onready var label = $Control/Panel/VBoxContainer/Label

signal show_info(info_text: String, choice: Array, item: Item, source: Node)

var popup_ref: CanvasLayer = null

func _ready():
	hide_menu()

func set_popup_menu(popup_menu: CanvasLayer):
	popup_ref = popup_menu

func display_inventory(label_text: String, inventory: Array[Item], player: Node):
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
		btn.connect("pressed", _on_player_item_pressed.bind(item, player))
		
		item_container.add_child(btn)
	
	# Wait for layout to update
	await get_tree().process_frame
	await get_tree().process_frame  # extra frame ensures layout is recalculated
	
	# Force VBoxContainer to recalc
	container.queue_sort()
	
	# Get correct size
	var container_size = container.get_combined_minimum_size()
	panel.size = container_size
	panel.position = Vector2(get_viewport().size.x - panel.size.x - 50, 50)
	
	visible = true


func hide_menu():
	visible = false

func _on_player_item_pressed(item: Item, player: Node):
	if popup_ref and popup_ref.visible:
		return
	
	var text := ""
	text += "Item: " + item.name + "\n\n"
	text += item.description + "\n"
	
	var choices = ["OK"] 
	if item.is_usable:
		choices.append("Use")
	if player.in_interaction:
		choices.append("Store")
	
	emit_signal("show_info", text, choices, item, player)
