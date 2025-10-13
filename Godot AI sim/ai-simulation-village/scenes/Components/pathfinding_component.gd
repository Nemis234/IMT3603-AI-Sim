extends Node
class_name PathfindingComponent

signal target_reached

@export var navigationNode: NavigationAgent2D
@export var movement_speed: float = 100.0

#The agent this component is bounded too
var agent: CharacterBody2D

#Bool to control emits
var _has_emitted: bool = false

func _ready():
	agent = get_parent() as CharacterBody2D

func set_target(new_target: Vector2):
	navigationNode.target_position = new_target
	_has_emitted = false

func move_along_path(delta: float) -> void:
	if !navigationNode.is_target_reached():
		var direction = agent.to_local(navigationNode.get_next_path_position()).normalized()
		agent.velocity = direction * movement_speed
		agent.move_and_slide()
	else:
		agent.velocity = Vector2.ZERO
		if !_has_emitted:
			target_reached.emit() #Emits signal that target is reached
			_has_emitted = true
			
func get_target_reached() -> bool:
	return navigationNode.is_target_reached()
