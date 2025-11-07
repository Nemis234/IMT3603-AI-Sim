class_name GameInputEvents

static var direction: Vector2

static func movement_input() -> Vector2:
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("walk_left"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("walk_right"):
		direction += Vector2.RIGHT
	if Input.is_action_pressed("walk_up"):
		direction += Vector2.UP
	if Input.is_action_pressed("walk_down"):
		direction += Vector2.DOWN
	
	direction = direction.normalized()
	
	return direction

static func is_movement_input() -> bool:
	if direction==Vector2.ZERO:
		return false
	else:
		return true

static func is_interact_input():
	if Input.is_action_just_pressed("interact"):
		return true
	
	return false

static  func is_quit_input():
	if Input.is_action_just_pressed("quit"):
		return true
	return false
