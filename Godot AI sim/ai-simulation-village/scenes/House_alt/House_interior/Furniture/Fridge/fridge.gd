extends interactable

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
signal request_popup(question: String, choises: Array)

#Changes state
func change_state(node: Node) -> void:
	if node.is_in_group("Player"):
		emit_signal("request_popup", "What would you like to take from the fridge?", ["Milk", "Egg", "Cheese", "Nothing"])
