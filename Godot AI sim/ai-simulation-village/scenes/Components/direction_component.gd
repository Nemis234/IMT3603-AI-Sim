extends Node
class_name DirectionComponent

var direction: Vector2 = Vector2.ZERO

#Usage example in another node: direction_component.set_direction(Vector2.RIGHT)
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func get_direction() -> Vector2:
	return direction
