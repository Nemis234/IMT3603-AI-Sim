extends Node
class_name AgentStatComponent

##Agent Stats
var stats: Dictionary = {
	"mood": 0,
	"hunger": 0,
	"tiredness": 0
}

#Progressbar
@onready var progressBar = $"../TextureProgressBar"

func _ready() -> void:
	stats["mood"] = 50
	stats["hunger"] = 50
	stats["tiredness"] = 30
	
func _process(delta: float) -> void:
	var minutes_passed = delta_minutes(delta)

	stats["mood"] -= minutes_passed * 0.01
	stats["hunger"] -= minutes_passed * 0.05
	stats["tiredness"] -= minutes_passed * 0.02
	
	# Clamp so stats don’t go negative
	for key in stats.keys():
		stats[key] = clamp(stats[key], 0, 100)
	

##Calculate every ingame minutes past
func delta_minutes(delta: float) -> float:
	var minutes_per_real_second = 1440 / Global.realSecondsPerIngameDay
	return delta * minutes_per_real_second

func update_stat(currentAction = null) -> void:
	#TODO maybe get values from the objects itself
	match currentAction:
		"read":
			stats["mood"] += 0.5
			update_progress_bar(stats["mood"])
		"eat":
			stats["hunger"] += 0.5
			update_progress_bar(stats["hunger"])
		"sleep":
			stats["tiredness"] += 0.1
			update_progress_bar(stats["tiredness"])
		_:
			pass

func update_progress_bar(value: float):
	progressBar.value = value

func show_progress_bar():
	progressBar.visible = true

func hide_progress_bar():
	progressBar.visible = false
