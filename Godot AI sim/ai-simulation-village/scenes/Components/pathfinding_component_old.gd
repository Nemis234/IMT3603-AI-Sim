extends Node
class_name PathfindingComponentOld

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false

#Call this to tell the agent where to go
func set_target(position: Vector2) -> void:
	target_position = position
	is_moving = true
	
#Returns a normalized direction to move toward the target
func get_direction(current_position: Vector2) -> Vector2:
	if not is_moving:
		return Vector2.ZERO
	
	var dir = target_position - current_position
	if dir.length() < 2.0: #Target reached #Increase this if agent overshoot and bounces
		is_moving = false
		return Vector2.ZERO

	return dir.normalized()
