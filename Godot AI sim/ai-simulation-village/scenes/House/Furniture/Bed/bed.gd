extends StaticBody2D

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#States of the furniture
enum State {
	INACTIVE = 0, 
	ACTIVE = 1
	}
	
#Current state of the entity
var currentState = State.INACTIVE

#Next state
var nextState = State.ACTIVE

func change_state() -> void:
	currentState = state_handler_component.change_state(nextState, currentState)
	
	#No changes in state
	if currentState != nextState:
		return

	match currentState:
		State.INACTIVE: nextState = State.ACTIVE
		_: nextState = State.INACTIVE

	if currentState == 1:
		print("Bed is in use.")
