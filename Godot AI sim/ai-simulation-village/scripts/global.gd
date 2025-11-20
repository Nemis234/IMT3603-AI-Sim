extends Node

##Global variables

#Related to ingame time
var time: float = 0.0 #0.0 Night, 1.0 Day , used for interpolating
var totalMinutes
var day = 1
var hour = 0
var minute = 0
var partOfDay = ""
const realSecondsPerIngameDay: float = 90.0 #One in game day is n real time seconds
var agent_houses: Dictionary #Holds every agent and their houses

##Related to saves
var selected_save: String = ""