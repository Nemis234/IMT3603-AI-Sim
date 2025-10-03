extends Node2D

@onready var player = $Adam


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_children():
		if node.is_in_group("Player"):
			node.interact.connect(_change_state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_physics_process(delta: float) -> void:
	print(player.curr_interactable)
	


func _change_state(entity,interactable):
	#print("signal sent",interactable.is_in_group("house_int"))
	if interactable.is_in_group("house_ext"):
		var house = interactable.get_parent()
		entity.position = house.exit_area.get_global_position()

	elif interactable.is_in_group("house_int"):
		print("Changing position")
		var house = interactable.get_parent()
		entity.position = house.door_area.get_global_position()

	elif interactable.is_in_group("interactable"):
		interactable.change_state()