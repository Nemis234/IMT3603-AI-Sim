extends interactable

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
@onready var bath_position = collisionArea.global_position
@onready var water: Sprite2D = $bathtub_water
@onready var bathtub: Sprite2D = $bathtub_empty
@onready var character: AnimatedSprite2D = $character
signal request_popup(question: String, choises: Array)


#Changes state
func change_state(node: Node) -> void:
	if node.is_in_group("Player"):
		node.curr_interactable = self
		emit_signal("request_popup", "Would you like to take a bath?", ["No", "Yes"])


func on_choice_made(choice_text: String) -> void:
	var init_position = player.global_position
	var init_direction = player.player_direction
	if choice_text == "Yes":
		# simulate player taking a bath
		player.hide()
		character.show()
		character.play(player.character + "_idle_front")
		water.show()
		
		# move player to center of bathtub to make camera focus on character in the bathtub
		player.global_position = bath_position
		player.player_direction = Vector2.DOWN
		await get_tree().create_timer(5).timeout # timer to simulate sleep
		water.hide()
		
		# set back to original state
		player.global_position = init_position
		player.player_direction = init_direction
		character.stop()
		character.hide()
		player.show()
	
	player.in_interaction = false #Set player out of interaction on making choice
