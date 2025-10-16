extends Node
class_name PathfindingComponent

signal target_reached

@export var navigationNode: NavigationAgent2D
@export var movement_speed: float = 50

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
		var new_velocity = direction * movement_speed
		
		#This part is to avoid agents getting stuck onto each other
		if navigationNode.avoidance_enabled:
			navigationNode.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		
		agent.move_and_slide()
	else:
		agent.velocity = Vector2.ZERO
		if !_has_emitted:
			target_reached.emit() #Emits signal that target is reached
			_has_emitted = true
			
func get_target_reached() -> bool:
	return navigationNode.is_target_reached()

##This is related to navigation avoidance
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	agent.velocity = safe_velocity
