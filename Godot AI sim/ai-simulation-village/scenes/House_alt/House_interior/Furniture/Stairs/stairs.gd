extends Node2D

signal stair_used(target_floor: String)

@export var target_stair: NodePath
@export var target_floor: String

# Stiars interact logic
func interact(player):
	# Set oposite stairs as target
	var target = get_node_or_null(target_stair)
	if target:
		# Use position of CollistionShape2D to move player
		var area = target.get_node_or_null("Area2D/CollisionShape2D")
		if area:
			player.global_position = area.global_position
		emit_signal("stair_used", target_floor)

# To integrate with LevelManager
func change_state():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		interact(player)
