extends Node2D

@onready var stair_up = $main_floor/StairsBottom
@onready var stair_down = $second_floor/StairsTop

@onready var up_area: Area2D = stair_up.get_node("Area2D")
@onready var down_area: Area2D = stair_down.get_node("Area2D")

func _ready() -> void:
	# Connect areas just like your doors
	up_area.body_entered.connect(_on_area_entered.bind("up"))
	up_area.body_exited.connect(_on_area_exited.bind("up"))

	down_area.body_entered.connect(_on_area_entered.bind("down"))
	down_area.body_exited.connect(_on_area_exited.bind("down"))

func _on_area_entered(body, area_name):
	if body.is_in_group("Player"):
		if area_name == "up":
			body.curr_interactable = stair_up
		elif area_name == "down":
			body.curr_interactable = stair_down

func _on_area_exited(body, area_name):
	if body.is_in_group("Player"):
		# Check if still inside the other area
		if area_name == "up" and down_area.get_overlapping_bodies().has(body):
			body.curr_interactable = stair_down
		elif area_name == "down" and up_area.get_overlapping_bodies().has(body):
			body.curr_interactable = stair_up
		else:
			body.curr_interactable = null
