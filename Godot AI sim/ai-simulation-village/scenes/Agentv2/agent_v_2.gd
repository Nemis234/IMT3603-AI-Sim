extends CharacterBody2D

@onready var detectionArea: Area2D = $Area2D
@onready var navigationNode: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed = 5000
@export var target: Vector2 = Vector2(400,400)


func _physics_process(delta: float) -> void:
	pass
	#TODO
#	navigationNode.target_position = target
	
	#if !navigationNode.is_target_reached():
	#	var direciton = to_local(navigationNode.get_next_path_position()).normalized()
	#	velocity = direciton * movement_speed * delta
	#	move_and_slide()

 
#testing
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == 69:
			for entities in detectionArea.get_overlapping_areas():
				if entities.get_parent().is_in_group("interactable"):
					entities.get_parent().change_state()
