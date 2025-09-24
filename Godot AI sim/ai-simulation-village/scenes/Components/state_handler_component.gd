extends Node

class_name StateHandlerComponent


func change_state(new_state: int, currentState: int) -> int:
	if currentState != new_state:
		return new_state
	else:
		return currentState
