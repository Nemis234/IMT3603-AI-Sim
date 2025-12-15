extends interactable


@export var state_handler_component: StateHandlerComponent
@export var change_state_sprite: ChangeStateSprite
@onready var collisionArea: CollisionShape2D = $CollisionShape2D
var curr_state = 0

#Changes state
func change_state(_node = null) -> void:
	state_handler_component.change_state(curr_state,collisionArea, change_state_sprite)
	
	
