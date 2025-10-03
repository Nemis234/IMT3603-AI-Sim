class_name Player
extends CharacterBody2D


var player_direction: Vector2
signal interact(entity,interactable)

var curr_interactable: Node =  null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and GameInputEvents.is_interact_input() and curr_interactable:
		print(self.curr_interactable)
		print("interacting with ",curr_interactable)
		emit_signal("interact",self,curr_interactable)
