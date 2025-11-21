extends interactable

 

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
@onready var bed_position = collisionArea.global_position
signal request_popup(question: String, choises: Array)
signal save

#Changes state
func change_state(node: Node) -> void:
	state_handler_component.change_state(0,collisionArea)
	if node.is_in_group("Player"):
		node.in_interaction = true
		node.curr_interactable = self
		emit_signal("request_popup", "Would you like to go to sleep? (Selecting 'Yes' will save your game)", ["No", "Yes"])

func on_choice_made(choice_text: String) -> void:
	var init_position = player.global_position
	var init_direction = player.player_direction
	if choice_text == "Yes":
		# move player to center of bed
		player.global_position = bed_position
		player.player_direction = Vector2.DOWN
		await get_tree().create_timer(5).timeout # timer to simulate sleep
		# move player back to old position
		player.global_position = init_position
		player.player_direction = init_direction
		
		emit_signal("save") #Emit save signal upon waking up
		print("Your game has been saved!")
	
	player.in_interaction = false #Set player out of interaction on making choice
	else: player.in_interaction = false
	
