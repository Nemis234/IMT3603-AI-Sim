extends Node
class_name WalkingAnimationComponent

@export var animated_sprite: AnimatedSprite2D

#Used to set the correct idle_facing animation
var last_facing: String = "right"

func update_animation(velocity: Vector2) -> void:
	if velocity.length() > 1.0:
		# Walking
		if velocity.x < 0:
			animated_sprite.play("walk_left")
			last_facing = "left"
		elif velocity.x > 0:
			animated_sprite.play("walk_right")
			last_facing = "right"
	else:
		# Idle based on last facing
		if last_facing == "left":
			animated_sprite.play("idle_left")
		else:
			animated_sprite.play("idle_right")
