extends Node2D

signal stair_used(target_floor: String)

@export var target_stair: NodePath
@export var target_floor: String

func interact(player):
	var target = get_node_or_null(target_stair)
	if target:
		var area = target.get_node_or_null("Area2D/CollisionShape2D")
		print(area)
		if area:
			player.global_position = area.global_position
		else:
			player.global_position = target.global_position  # fallback
		emit_signal("stair_used", target_floor)

# To integrate with your LevelManager
func change_state():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		interact(player)
