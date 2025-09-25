extends StaticBody2D

@export var state_handler_component: StateHandlerComponent
@export var change_state_sprite: ChangeStateSprite
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#States of the furniture
enum State {
	OFF = 0, 
	ON = 1
	}
	
#Current state of the entity
var currentState = State.OFF

#Next state
var nextState = State.ON

#Changes state
func change_state() -> void:
	currentState = state_handler_component.change_state(nextState, currentState)
	
	#No changes in state
	if currentState != nextState:
		return
	
	#Change animation upon state change
	change_state_sprite.change_sprite()
	
	match currentState:
		State.OFF: nextState = State.ON
		_: nextState = State.OFF
	
	if currentState == 1:
		print("TV is on.")
