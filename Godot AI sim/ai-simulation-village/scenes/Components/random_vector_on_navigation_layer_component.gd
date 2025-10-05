extends Node
class_name RandomVectorOnNavigationLayerComponent

var mainMapLayer
var house1Layer

func _ready() -> void:
	for elements in get_tree().get_nodes_in_group("NavigationArea"):
		if elements.name == "WalkAbleTilesMainMap":
			mainMapLayer = elements
		elif elements.name == "WalkAbleTilesHouse1":
			house1Layer = elements

#Get a random Vector from Main map
func get_random_target_main_map() -> Vector2:
	var cells = mainMapLayer.get_used_cells()
	if cells.is_empty():
		return Vector2.ZERO

	var random_cell = cells.pick_random()
	var local_pos = mainMapLayer.map_to_local(random_cell)
	var world_pos = mainMapLayer.to_global(local_pos)
	return world_pos
	
#Get a random Vector from a given section, used for inside buildings
func get_random_target_in_building(buildingName: String) -> Vector2:
	match buildingName:
		"House":
			print("House called")
			var cells = house1Layer.get_used_cells()
			if cells.is_empty():
				return Vector2.ZERO

			var random_cell = cells.pick_random()
			var local_pos = house1Layer.map_to_local(random_cell)
			var world_pos = house1Layer.to_global(local_pos)
			return world_pos
		_: 
			print("Could not get random tile to pathfind")
			return Vector2(0,0)

#TODO Make a new func to retrive random cell and conversion
