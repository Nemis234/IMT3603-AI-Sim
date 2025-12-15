extends Node

var ITEMS = {
	"Gold coin": Item.new("Gold coin", "The normal currency in this village"),
	"Bread": Item.new("Bread", "A loaf of bread made by the local bakery", true),
	"Cloth": Item.new("Cloth","Just a pice of cloth, nothing special"),
	"Egg": Item.new("Egg", "A delicious egg from the local farm", true),
	"Bacon": Item.new("Bacon", "A strip of high quality bacon", true)
}

func get_item(item_id: String) -> Item:
	if ITEMS.has(item_id):
		return ITEMS[item_id].duplicate() as Item
	return null
