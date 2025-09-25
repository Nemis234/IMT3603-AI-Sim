extends CharacterBody2D

@onready var navigationNode: NavigationAgent2D = $NavigationAgent2D

@export var movement_speed = 5000
@export var target: Vector2 = Vector2(400,400)



func _physics_process(delta: float) -> void:
	#TODO
	navigationNode.target_position = target
	
	if !navigationNode.is_target_reached():
		var direciton = to_local(navigationNode.get_next_path_position()).normalized()
		velocity = direciton * movement_speed * delta
		move_and_slide()
