extends Control

@onready var label: Label = $PanelContainer/MarginContainer/Label

var target_node: Node2D
var offset := Vector2(0, -50)  # pixels above the target
var lifetime := 0.0            # 0 = stay forever

func show_text(text: String, target: Node2D, seconds: float = 0.0):
    label.text = text
    target_node = target
    lifetime = seconds
    visible = true
    if lifetime > 0:
        await get_tree().create_timer(lifetime).timeout
        queue_free()

func _process(_delta):
    if not target_node or not target_node.is_inside_tree():
        queue_free()
        return
    # convert target position (global) to screen coords
    var screen_pos = target_node.get_global_transform_with_canvas().origin + offset
    global_position = screen_pos
