extends interactable

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
signal request_popup(question: String, content: Array)

#Changes state
func change_state(node: Node) -> void:
	state_handler_component.change_state(0,collisionArea)
	print(node)
	if node.is_in_group("Player"):
		node.curr_interactable = self
		emit_signal("request_popup", "What book would you like to read?", 
			[
				"A students guide to frode-kode", 
				"The holy bibl", 
				"Union of Markus and Bernt",
				"Nothing"
			]
		)
