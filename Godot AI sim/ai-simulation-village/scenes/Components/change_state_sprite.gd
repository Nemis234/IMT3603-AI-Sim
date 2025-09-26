extends Node

class_name ChangeStateSprite

@export var sprite_1: Sprite2D
@export var sprite_2: Sprite2D

var currentSprite


func _ready() -> void:
#Make sures that sprite 1 is visible at initializing
	sprite_1.visible = true
	sprite_2.visible = false
	currentSprite = sprite_1

func change_sprite() -> void:
	if currentSprite == sprite_1:
		sprite_1.visible = false
		sprite_2.visible = true
		currentSprite = sprite_2
	else:
		sprite_1.visible = true
		sprite_2.visible = false
		currentSprite = sprite_1
