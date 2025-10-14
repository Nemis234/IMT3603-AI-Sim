extends NodeState

@export var player: Player
@export var animated_sprite_2D: AnimatedSprite2D
@export var speed : int = 100

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	if player.in_dialogue:
		transition.emit("Idle") #Transition to idle state and not accept any movement input if player engaged in dialogue
		return 
	
	var direction = GameInputEvents.movement_input()
			
	if direction == Vector2.UP:
		animated_sprite_2D.play("walk_back")
	elif direction == Vector2.DOWN:
		animated_sprite_2D.play("walk_front")
	elif direction == Vector2.LEFT:
		animated_sprite_2D.play("walk_left")
	elif direction == Vector2.RIGHT:
		animated_sprite_2D.play("walk_right")
	
	if direction!=Vector2.ZERO:
		player.player_direction = direction
	
	player.velocity = direction * speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	if !GameInputEvents.is_movement_input():
		transition.emit("Idle")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2D.stop()
