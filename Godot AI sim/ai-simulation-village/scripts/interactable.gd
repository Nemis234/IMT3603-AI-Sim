class_name interactable
extends Node2D

@onready var interact_area: Area2D = $Area2D
var on_mouse: bool = false #To check mouse is hoverd over
var player_in_area: bool = false #To check if player entered the area
@onready var player: Player = get_tree().root.get_node("LevelManager/Adam")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)
	interact_area.mouse_entered.connect(_on_mouse_entered)
	interact_area.mouse_exited.connect(_on_mouse_exited)
	interact_area.input_event.connect(_on_area_input_event)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true 
		
func _on_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false 

func change_state(node:Node)->void:
	pass		

func _on_mouse_entered():
	interact_area.modulate = Color(1, 1, 0.6) # highlight
	on_mouse = true
	print("Mouse entered",name)

func _on_mouse_exited():
	interact_area.modulate = Color(1, 1, 1) # remove highlight
	on_mouse = false
	print("Mouse exited",name)

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and player_in_area:
		change_state(player)
		print("Clicked on area:", name)
	
		
