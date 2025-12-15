extends interactable

@onready var house = self.get_parent()

func _ready() -> void:
	interact_area = $Entrance #Redeclaring interact area cause Area2D name is different for houses
	super()

func change_state(node:Node)->void:
	if node and node.is_in_group("Player"):
		node.position = house.door_area.get_global_position() #Let player exit house
