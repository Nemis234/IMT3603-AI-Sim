extends  StateHandlerComponent

func change_state(current_state,has_collision: CollisionShape2D = null, has_sprite_change: ChangeStateSprite = null) -> void:

	var door: StaticBody2D = has_collision.get_parent()
	# toggle state
	var new_state = State.ACTIVE if current_state == State.INACTIVE else State.INACTIVE

	if new_state == current_state:
		return  # nothing changed

	if has_collision != null:
		if current_state == State.INACTIVE:
			door.collision_layer = 2
		else:
			door.collision_layer = 1

	if has_sprite_change != null:
		has_sprite_change.change_sprite()
	
	door.curr_state = new_state
