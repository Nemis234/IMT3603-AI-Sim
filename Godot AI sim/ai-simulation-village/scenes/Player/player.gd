class_name Player
extends CharacterBody2D


var player_direction: Vector2
var in_dialogue: bool = false #Keep track if player is engaging with an agent in dialogue
var recipient_in_convo: Agent = null # To stroe the agent the player is interacting with

#signal interact(entity,interactable) #Signal for general interactions
signal end_convo(agent) #Signal to indicate ending of conversation


#var curr_agent: Agent = null #To store the current agent the player is interacting with (for chat purposes)

@onready var interact_area : Area2D = $Area2D
var nearby_objects: Array = [] #To store nearby objects

func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	
	#Send signal to allow user to quit chatting with agent
	if event is InputEventKey and GameInputEvents.is_quit_input() and recipient_in_convo:
		if recipient_in_convo.is_in_group("Agent"):
			emit_signal("end_convo",recipient_in_convo)
		pass
