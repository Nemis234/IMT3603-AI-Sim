class_name Player
extends CharacterBody2D


var player_direction: Vector2
var in_dialogue: bool = false #Keep track if player is engaging with an agent in dialogue

signal interact(entity,interactable) #Signal for general interactions
signal end_convo(agent) #Signal to indicate ending of conversation

var curr_interactable: Node =  null
#var curr_agent: Agent = null #To store the current agent the player is interacting with (for chat purposes)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and GameInputEvents.is_interact_input() and curr_interactable:
		print(self.curr_interactable)
		print("interacting with ",curr_interactable)
		emit_signal("interact",self,curr_interactable)
	
	#Send signal to allow user to quit chatting with agent
	if event is InputEventKey and GameInputEvents.is_quit_input() and curr_interactable:
		if curr_interactable.is_in_group("Agent"):
			emit_signal("end_convo",curr_interactable)
		pass
