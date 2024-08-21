## A Node representing the point of an n-gram.  
## [br] [br]
## Should be mouse-dragable.
class_name NGramPoint
extends Area2D

signal moved(pos: Vector2)

var is_mouse_over: bool = false
var is_dragged: bool = false

func _process(_delta: float) -> void:
	# if the point is currently being dragged by the mouse, move to the
	# position of the mouse
	if is_dragged:
		if global_position != get_global_mouse_position():
			global_position = get_global_mouse_position()
			moved.emit(global_position)
	
	if Input.is_action_just_pressed("left_click") and is_mouse_over:
		is_dragged = true
	if is_dragged and Input.is_action_just_released("left_click"):
		is_dragged = false

func _on_mouse_entered():
	is_mouse_over = true

func _on_mouse_exited():
	is_mouse_over = false
