class_name interactable
extends StaticBody2D

@onready var interact_area: Area2D = $Area2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_entered(body):
	if body.is_in_group("Player"):
		body.curr_interactable = self
		
func _on_exited(body):
	if body.is_in_group("Player"):
			body.curr_interactable = null

func change_stae()->void:
	pass		

	
		
