extends Node2D

@onready var canvasMod: CanvasModulate = $CanvasModulate
@export var skyGradient: GradientTexture1D


##This function set the value for the canvas modulate.
func setDayNightColor(time: float) -> void:
	var colorFromGradient = skyGradient.gradient.sample(time)
	
	#Blend the original + n white to desaturate
	#Adjust the float to change n 
	colorFromGradient = colorFromGradient.lerp(Color(1,1,1), 0.3)
	
	canvasMod.color = colorFromGradient

func hideDayNightFilter(state: String) -> void:
	if state.to_lower() == "hide":
		canvasMod.visible = false
	else:
		canvasMod.visible = true
