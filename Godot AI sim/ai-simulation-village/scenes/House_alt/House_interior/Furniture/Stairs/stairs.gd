extends StaticBody2D

signal stair_used(target_floor: String)

@export var target_stair_path: NodePath
@export var target_floor: String

func interact(player: Player):
	# Called when Player interacts
	var target_stair = get_node_or_null(target_stair_path)
	if target_stair:
		player.global_position = target_stair.global_position
		emit_signal("stair_used", target_floor)
