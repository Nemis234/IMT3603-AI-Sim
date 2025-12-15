class_name Player
extends CharacterBody2D

@onready var inventory: Inventory = $Inventory

var player_direction: Vector2
var in_dialogue: bool = false #Keep track if player is engaging with an agent in dialogue
var in_interaction:bool = false #Keep track if player is engaging with an object
var in_object_inventory: bool = false
var curr_interactable: Node = null
var recipient_in_convo: Agent = null # To stroe the agent the player is interacting with
var is_open: bool = false
@export var character: String = "rafael"

signal end_convo(agent) #Signal to indicate ending of conversation
signal open_inventory(label_text: String, inventory: Array[Item])
signal close_inventory


#var curr_agent: Agent = null #To store the current agent the player is interacting with (for chat purposes)

@onready var interact_area : Area2D = $Area2D
var nearby_objects: Array = [] #To store nearby objects

func _ready() -> void:
	inventory.add_item("Gold coin", 5)
	inventory.add_item("Bread", 2)
	inventory.remove_item("Bread", 1)
	pass


func _unhandled_input(event: InputEvent) -> void:
	
	#Send signal to allow user to quit chatting with agent
	if event is InputEventKey and GameInputEvents.is_quit_input() and recipient_in_convo:
		if recipient_in_convo.is_in_group("Agent"):
			emit_signal("end_convo",recipient_in_convo)
		pass
	
	if event.is_action_pressed("inventory") and !is_open:
		emit_signal("open_inventory", "Your current inventory", inventory.items, self)
		is_open = true
	elif event.is_action_pressed("inventory") and is_open:
		emit_signal("close_inventory")
		is_open = false

#Gets the opposite direction of the player direction as a string
func get_opposite_direction()->String:
	if player_direction == Vector2.UP:
		return "front"
	elif player_direction == Vector2.DOWN:
		return "back"
	elif player_direction == Vector2.LEFT:
		return "right"
	elif player_direction == Vector2.RIGHT:
		return "left"
	
	return ""

#Getter to retrieve player details
func get_player_details()-> Dictionary:
	return {
		"position": self.position,
		"player_direction": player_direction,
		"character": character,
		"inventory":  inventory.get_inventory()
	}

#Setter to set agent details (While loading a save)
func set_player_details(details:Dictionary) -> void:
	self.position = details["position"]
	self.player_direction = details["player_direction"]
	self.character = details["character"]
	self.inventory.set_inventory(details["inventory"])
