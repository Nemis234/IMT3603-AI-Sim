extends Node
class_name RandomVectorOnNavigationLayerComponent

var mainMapLayer

func _ready() -> void:
	for elements in get_tree().get_nodes_in_group("NavigationArea"):
		if elements.name == "WalkAbleTilesMainMap":
			mainMapLayer = elements


#Get a random cell and convert to global pos from given tilemaplayer
func _get_random_cell_and_convert(mapLayer:TileMapLayer) -> Vector2:
	var cells = mapLayer.get_used_cells()
	if cells.is_empty():
		return Vector2.ZERO

	var random_cell = cells.pick_random()
	var local_pos = mapLayer.map_to_local(random_cell)
	var world_pos = mapLayer.to_global(local_pos)
	return world_pos

#Get a random Vector from Main map
func get_random_target_main_map() -> Vector2:
	return _get_random_cell_and_convert(mainMapLayer)
	
##Get a random Vector from a given section, used for inside buildings.
##building is the node of the building
func get_random_target_in_building(building: Node2D) -> Vector2:
	
	var navigationTiles = building.navigationTilesMainFloor
	if !navigationTiles:
		print("Could not get random tile to pathfind")
		return Vector2(0,0)
	
	return _get_random_cell_and_convert(navigationTiles)
