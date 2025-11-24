extends interactable

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
@onready var inventory: Inventory = $Inventory

signal open_inventory(label_text: String, inventory: Array[Item], source: Node, mode: String)

func fill_fridge() -> void:
	inventory.add_item("Egg", 6)
	inventory.add_item("Bacon", 3)
	inventory.remove_item("Bacon", 2)

#Changes state
func change_state(node: Node) -> void:
	if node.is_in_group("Player"):
		node.in_interaction = true
		node.curr_interactable = self
		emit_signal("open_inventory", "Fridge inventory", inventory.items)

func on_choice_made(choice_text: String) -> void:
	pass
