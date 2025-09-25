extends StaticBody2D

@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#States of the furniture
enum State {
	CLOSED = 0, 
	OPEN = 1
	}
	
#Current state of the entity
var currentState = State.CLOSED

#Next state
var nextState = State.OPEN

func change_state() -> void:
	currentState = state_handler_component.change_state(nextState, currentState)
	
	#No changes in state
	if currentState != nextState:
		return

	match currentState:
		State.CLOSED: nextState = State.OPEN
		_: nextState = State.CLOSED

	if currentState == 1:
		print("Fridge is in use.")
