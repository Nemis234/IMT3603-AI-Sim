extends StaticBody2D

#States of the furniture
enum State {
	CLOSED = 0, 
	OPEN = 1
	}
	
#Current state of the entity
var currentState = State.CLOSED

#List of entities within range
var allBodiesWithinRange: Array = []

#testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == 69:
			print(currentState)
			print(allBodiesWithinRange)
			


func _on_area_2d_body_entered(body: Node2D) -> void:
	allBodiesWithinRange.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	allBodiesWithinRange.erase(body)
