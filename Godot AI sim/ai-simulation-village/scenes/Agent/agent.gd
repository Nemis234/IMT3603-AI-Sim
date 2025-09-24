extends CharacterBody2D

@export var direction_component: DirectionComponent
@export var velocity_component: VelocityComponent
@export var pathfinding_component: PathfindingComponent 
@export var walking_animation_component: WalkingAnimationComponent

#Testing purposes
@export var move_to_target: Vector2

#List of entities/objects within range
var allBodiesWithinRange: Array = []

#Pathfinding, check if something is blocking the agent on x-axis or y-axis
var collision_axis: String = ""

func _physics_process(delta: float) -> void:
	#Decide target, target could be an entity in the game
	#This way we could let the LLM decide where to go without querying every direction
	pathfinding_component.set_target(move_to_target) #Example

	#Use the pathfinding function to get the next direction towards target
	#From current direction
	var move_dir = pathfinding_component.get_direction(global_position)
	
	#Feed the data from pathfinder_component into direction_component
	direction_component.set_direction(move_dir, collision_axis)

	#Update the velocity
	velocity_component.accelerate_towards(direction_component.get_direction(), delta)
	velocity = velocity_component.get_velocity()
	
	#Move the agent
	move_and_slide()
	
	#Let the animation_component handle animations
	walking_animation_component.update_animation(velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	#TODO under work
	var dir = body.global_position - global_position
	if abs(dir.x) > abs(dir.y):
		# Horizontal collision
		if dir.x > 0:
			collision_axis = "X"
	else:
		# Vertical collision
		if dir.y > 0:
			collision_axis = "Y"
			
	#Store all the bodies within interactable range
	allBodiesWithinRange.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	#TODO underwork
	collision_axis = ""
	
	#Remove the bodies within interactable range
	allBodiesWithinRange.erase(body)


#testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == 69:
			for entities in allBodiesWithinRange:
				if entities.is_in_group("interactable"):
					entities.change_state()
			
