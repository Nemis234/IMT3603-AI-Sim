extends Node
class_name RandomVectorOnNavigationLayerComponent

var mainMapLayer

func _ready() -> void:
	for elements in get_tree().get_nodes_in_group("NavigationArea"):
		if elements.name == "WalkAbleTiles":
			mainMapLayer = elements

#Get a random Vector from Main map
func get_random_target_main_map() -> Vector2:
	var cells = mainMapLayer.get_used_cells()
	if cells.is_empty():
		return Vector2.ZERO

	var random_cell = cells.pick_random()
	var local_pos = mainMapLayer.map_to_local(random_cell)
	var world_pos = mainMapLayer.to_global(local_pos)
	return world_pos
