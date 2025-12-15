extends Node

class_name StateHandlerComponent

# States
enum State {
	INACTIVE = 0,
	ACTIVE = 1
}


func change_state(current_state,has_collision: CollisionShape2D = null, has_sprite_change: ChangeStateSprite = null) -> void:
	
	# toggle state
	var new_state = State.ACTIVE if current_state == State.INACTIVE else State.INACTIVE

	if new_state == current_state:
		return  # nothing changed

	if has_collision != null:
		if current_state == State.INACTIVE:
			has_collision.visible = true
		else:
			has_collision.visible = false

	if has_sprite_change != null:
		has_sprite_change.change_sprite()
