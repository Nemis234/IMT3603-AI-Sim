extends Node2D

func _ready():
	var player = $Player
	#player.connect("interact", _on_player_interact)
#
	#$StairUp.connect("stair_used", _on_stair_used)
	#$StairDown.connect("stair_used", _on_stair_used)

func _on_player_interact(player, target):
	if target.has_method("interact"):
		target.interact(player)

func _on_stair_used(target_floor: String):
	for floor_node in $Floors.get_children():
		floor_node.visible = (floor_node.name == target_floor)
