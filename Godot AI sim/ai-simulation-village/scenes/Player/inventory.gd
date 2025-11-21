extends Node
class_name Inventory

var items: Array[Item] = []

func add_item(item_id: String, amount: int = 1):
	var new_item = ItemDatabase.get_item(item_id)
	if new_item == null:
		push_error("Item '%s' not found in database" % item_id)
		return
	
	# Stack if possible
	for existing_item in items:
		if existing_item.name == new_item.name:
			existing_item.add_quantity(amount)
			return
	
	# Otherwise, add new instance
	new_item.quantity = amount
	items.append(new_item)


func remove_item(item_id: String, amount: int = 1):
	for item in items:
		if item.name == item_id and item.quantity >= amount:
			item.remove_quantity(amount)
			if item.quantity <= 0:
				items.erase(item)
			return
