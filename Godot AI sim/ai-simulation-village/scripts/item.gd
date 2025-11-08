class_name  Item

var name: String 
var description: String
var quantity: int

func _init(item_name: String, item_description: String ="", item_quantity: int = 1):
	self.name = item_name
	self.description = item_description
	self.quantity = item_quantity
