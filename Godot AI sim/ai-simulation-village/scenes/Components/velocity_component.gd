extends Node
class_name VelocityComponent

@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

var velocity: Vector2 = Vector2.ZERO

#Usage example in another node:
#velocity_component.accelerate_towards(direction_component.get_direction(), delta) 
func accelerate_towards(direction: Vector2, delta: float) -> void:
	if direction.length() > 0:
		# Accelerate in the desired direction
		velocity = velocity.move_toward(direction.normalized() * max_speed, acceleration * delta)
	else:
		# Apply friction when no input is given (used for non humanoid movement)
		#velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		#Stops the entity at desired location
		velocity = Vector2.ZERO
		
		#Maybe implement some clamp function later

func get_velocity() -> Vector2:
	return velocity
