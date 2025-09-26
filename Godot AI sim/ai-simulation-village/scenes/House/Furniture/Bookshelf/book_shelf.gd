extends StaticBody2D

<<<<<<< HEAD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
=======
@export var state_handler_component: StateHandlerComponent
@onready var collisionArea: CollisionShape2D = $CollisionShape2D

#Changes state
func change_state() -> void:
	state_handler_component.change_state(0,collisionArea)
	print("Interacted with Bookshelf")
>>>>>>> 552d9b9bf194833acc1d4cb8620e0391df3a1c92
