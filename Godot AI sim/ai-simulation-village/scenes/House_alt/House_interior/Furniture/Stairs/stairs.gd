extends interactable

signal stair_used(target_floor: String)
@warning_ignore("unused_signal")
signal request_popup(question: String, content: Array)

@export var target_stair: NodePath
@export var target_floor: String

# Stiars interact logic
func interact_(_player):
	# Set oposite stairs as target
	var target = get_node_or_null(target_stair)
	if target:
		# Use position of CollistionShape2D to move player
		var area = target.get_node_or_null("Area2D/CollisionShape2D")
		if area:
			player.global_position = area.global_position
		emit_signal("stair_used", target_floor)

# To integrate with LevelManager
func change_state(entity):
	if entity:
		interact_(entity)
