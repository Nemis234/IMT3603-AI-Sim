extends CharacterBody2D

@export var direction_component: DirectionComponent
@export var velocity_component: VelocityComponent
@export var pathfinding_component: PathfindingComponent 

func _physics_process(delta: float) -> void:
	#Decide target, target could be an entity in the game
	#This way we could let the LLM decide where to go without querying every direction
	pathfinding_component.set_target(Vector2(400,300)) #Example

	#Use the pathfinding function to get the next direction towards target
	#From current direction
	var move_dir = pathfinding_component.get_direction(global_position)
	
	#Feed the data from pathfinder_component into direction_component
	direction_component.set_direction(move_dir)

	#Update the velocity
	velocity_component.accelerate_towards(direction_component.get_direction(), delta)
	velocity = velocity_component.get_velocity()
	
	#Move the agent
	move_and_slide()
