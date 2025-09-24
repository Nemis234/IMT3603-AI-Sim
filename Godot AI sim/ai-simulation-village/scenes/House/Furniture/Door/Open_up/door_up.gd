extends StaticBody2D

#States of the furniture
enum State {
	CLOSED = 0, 
	OPEN = 1
	}
	
#Current state of the entity
var currentState = State.CLOSED
