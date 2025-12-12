extends Control

#const LEVEL_MANAGER := preload("res://scenes/LevelManager/level_manager.tscn")

var player: Player
var agent1: Agent
var agent2: Agent
var agent3: Agent
var agent4: Agent


var player_character := ""
var agent1_character := "john"
var agent2_character := "mei"
var agent3_character := "rafael"
var agent4_character := "ethan"

var available_characters := [
	"adrian","clara","eleanor","ethan","gregory","harold","isabella",
	"marcus","marianne","martha","rafael","richard","thomas","valentina"
]

func remove_character(character: String) -> void:
	available_characters.erase(character)

func init_agent_characters() -> void:
	agent1_character = available_characters.pick_random()
	remove_character(agent1_character)
	agent2_character = available_characters.pick_random()
	remove_character(agent2_character)

func change_to_level_manager() -> void:
	print("Adding levelmanager")
	# Create and set the new scene without destroying this node yet
	var LEVEL_MANAGER = load("res://scenes/LevelManager/level_manager.tscn")
	var lm = LEVEL_MANAGER.instantiate()
	get_tree().root.add_child(lm)
	get_tree().current_scene = lm

	 #Now it's safe to fetch nodes and assign
	player = lm.get_node("Adam") as Player
	agent1 = lm.get_node("Agent1") as Agent
	agent2 = lm.get_node("AgentV2") as Agent	
	agent3 = lm.get_node("AgentV3") as Agent
	agent4 = lm.get_node("AgentV4") as Agent
	
	player.character = player_character
	agent1.character = agent1_character
	agent2.character = agent2_character
	agent3.character = agent3_character
	agent4.character = agent4_character

	 #Remove the old (character select) scene
	queue_free()

func _on_character_pressed(character_name: String) -> void:
	player_character = character_name
	remove_character(player_character)
	#init_agent_characters()
	change_to_level_manager()

# Button handlers:
func _on_adrian_button_pressed() -> void:    _on_character_pressed("adrian")
func _on_clara_button_pressed() -> void:     _on_character_pressed("clara")
func _on_eleanor_button_pressed() -> void:   _on_character_pressed("eleanor")
#func _on_ethan_button_pressed() -> void:     _on_character_pressed("ethan")
func _on_gregory_button_pressed() -> void:   _on_character_pressed("gregory")
func _on_harold_button_pressed() -> void:    _on_character_pressed("harold")
func _on_isabella_button_pressed() -> void:  _on_character_pressed("isabella")
func _on_marcus_button_pressed() -> void:    _on_character_pressed("marcus")
func _on_marianne_button_pressed() -> void:  _on_character_pressed("marianne")
func _on_martha_button_pressed() -> void:    _on_character_pressed("martha")
#func _on_rafael_button_pressed() -> void:    _on_character_pressed("rafael")
func _on_richard_button_pressed() -> void:   _on_character_pressed("richard")
func _on_thomas_button_pressed() -> void:    _on_character_pressed("thomas")
func _on_valentina_button_pressed() -> void: _on_character_pressed("valentina")
