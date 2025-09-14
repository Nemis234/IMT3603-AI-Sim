extends Node2D

func _ready():
	
	#Centers the Node to viewport
	var viewport_center = get_viewport_rect().size / 2.0
	position = viewport_center
