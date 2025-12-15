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

func get_inventory()-> Array:
	var inventory_details = []
	for item in items:
		inventory_details.append(item.get_item_meta_data())
	
	return inventory_details

func set_inventory(inventory_details:Array):
	items = []
	for item_dict in inventory_details:
		items.append(Item.new(item_dict["name"],item_dict["description"], item_dict["is_usable"],item_dict["quantity"]))
