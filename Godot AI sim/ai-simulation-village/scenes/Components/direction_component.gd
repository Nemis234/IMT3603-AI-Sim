extends Node
class_name DirectionComponent

var direction: Vector2 = Vector2.ZERO

#Usage example in another node: direction_component.set_direction(Vector2.RIGHT)
func set_direction(dir: Vector2, collision_dir: String) -> void:
	#Check whenever agent collides with an object on the X- or Y-axis
	match collision_dir:
		"X":
			direction = Vector2(0,1)
		"Y":
			direction = Vector2(1,0)
		_:
			direction = dir.normalized()

func get_direction() -> Vector2:
	return direction
