extends Node

##Global variables

#Related to ingame time
var time: float = 0.0 #0.0 Night, 1.0 Day , used for interpolating
var totalMinutes
var hour
var minute
var partOfDay = ""
const realSecondsPerIngameDay: float = 60.0 #One in game day is n real time seconds
