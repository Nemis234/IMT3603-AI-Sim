extends interactable

@export var state_handler_component: StateHandlerComponent
@export var change_state_sprite: ChangeStateSprite
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#Changes state
func change_state(node:Node) -> void:
	state_handler_component.change_state(0,collisionArea)
