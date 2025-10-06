extends Node2D

@onready var house_interior = $house_interior
@onready var house_exterior = $house_exterior


@onready var door_area: Area2D = house_exterior.get_node("Entrance")
@onready var exit_area: Area2D = house_interior.get_node("Entrance")




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door_area.body_entered.connect(_on_doorstep_entered.bind("door_step"))
	door_area.body_exited.connect(_on_doorstep_exited)
	
	exit_area.body_entered.connect(_on_doorstep_entered.bind("exit"))
	exit_area.body_exited.connect(_on_doorstep_exited)

func _on_doorstep_entered(body,area):
	if body.is_in_group("Player"):
		if area=="door_step":
			body.curr_interactable = self.house_exterior
		elif area=="exit":
			body.curr_interactable = self.house_interior
		print(body.curr_interactable)
		
func _on_doorstep_exited(body):
	if body.is_in_group("Player"):
		if door_area.get_overlapping_bodies().has(body): #On exiting the (exterior) door_area, if you land in the (interior) exit_area
			body.curr_interactable = self.house_exterior
		elif exit_area.get_overlapping_bodies().has(body): #On exiting the (interior) door_area, if you land in the (exterior) door_area
			body.curr_interactable = self.house_interior
		else: #If you just walk out/leave of the area normally
			body.curr_interactable = null
		print(body.curr_interactable)
