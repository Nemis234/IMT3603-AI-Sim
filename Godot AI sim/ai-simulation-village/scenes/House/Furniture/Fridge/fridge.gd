extends StaticBody2D

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#Changes state
func change_state() -> void:
	state_handler_component.change_state(0,collisionArea)
	print("Interacted with Fridge")
