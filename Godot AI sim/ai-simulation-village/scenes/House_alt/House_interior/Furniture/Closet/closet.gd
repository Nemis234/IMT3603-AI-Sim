extends interactable

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
signal request_popup(question: String, content: Array)

#Changes state
func change_state(node: Node) -> void:
	state_handler_component.change_state(0,collisionArea)
	if node.is_in_group("Player"):
		emit_signal("request_popup", "Waht would you like to tak out of the closet?", 
			[
				"Jacket", 
				"Pants", 
				"T-shirt", 
				"Skeletons", 
				"Nothing"
			]
		)
	print("Interacted with Closet")
