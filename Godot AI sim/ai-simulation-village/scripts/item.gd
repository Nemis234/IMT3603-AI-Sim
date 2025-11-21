extends Resource
class_name  Item

@export var name: String
@export var description: String
@export var is_usable: bool
@export var quantity: int = 1

func _init(item_name: String = "", item_description: String = "", item_is_usable: bool = false, item_quantity: int = 1):
	self.name = item_name
	self.description = item_description
	self.is_usable = item_is_usable
	self.quantity = item_quantity

func add_quantity(amount: int):
	quantity += amount
	
func remove_quantity(amount: int):
	quantity = max(quantity - amount, 0)
