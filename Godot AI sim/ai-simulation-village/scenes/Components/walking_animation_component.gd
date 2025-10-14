extends Node
class_name WalkingAnimationComponent

@export var animated_sprite: AnimatedSprite2D
@export var agent: Agent
var last_facing: String = "down"

# Small threshold to ignore tiny movement jitter/animation flickering
const MOVE_THRESHOLD := 10.0

func update_animation(velocity: Vector2) -> void:
	
	var speed = velocity.length()
	if speed > MOVE_THRESHOLD:
		# Determine dominant axis (whichever has larger magnitude)
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				set_facing("right")
			else:
				set_facing("left")
		else:
			if velocity.y > 0:
				set_facing("down")
			else:
				set_facing("up")

		# Play walking animation in current facing
		animated_sprite.play("walk_%s" % last_facing)
	else:
		# Idle animation based on last facing
		animated_sprite.play("idle_%s" % last_facing)

func set_facing(direction: String) -> void:
	if last_facing != direction:
		last_facing = direction
