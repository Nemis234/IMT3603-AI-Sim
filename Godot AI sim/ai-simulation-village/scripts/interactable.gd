class_name interactable
extends Node2D

@onready var interact_area: Area2D = get_node_or_null("Area2D")
var on_mouse: bool = false #To check mouse is hoverd over
var player_in_area: bool = false #To check if player entered the area
#@onready var player: Player = get_tree().root.get_node("LevelManager/Adam")
@onready var player: Player = get_tree().get_root().find_child("Adam", true, false) # searches for the node recursively



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)
	interact_area.mouse_entered.connect(_on_mouse_entered)
	interact_area.mouse_exited.connect(_on_mouse_exited)
	interact_area.input_event.connect(_on_area_input_event)


func _on_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true 
		
func _on_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false 

func change_state(_node:Node)->void:
	if _node.is_in_group("Player"):
		_node.in_interaction = true
		_node.curr_interactable = self
			

func _on_mouse_entered():
	interact_area.modulate = Color(1, 1, 0.6) # highlight
	on_mouse = true


func _on_mouse_exited():
	interact_area.modulate = Color(1, 1, 1) # remove highlight
	on_mouse = false


func _on_area_input_event(_viewport, event:InputEvent, _shape_idx):
	if event.is_action_pressed("interact") and player_in_area:
		change_state(player)
		print("Clicked on area:", name)


func on_choice_made(choice_text: String) -> void:
	player.in_interaction = false #Set player out of interaction on making choice