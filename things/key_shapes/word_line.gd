class_name WordLine
extends Line2D

## a signal emitted when the final segment is completed, allowing the next line to be animated
signal finished_drawing

## DEPRECATED [br]
## how long each segment takes to animate
@export var seg_animation_time: float = 0.75

## how fast the line_end_point moves in pixels/s
@export var animation_speed: float = 50

## the points that the line will animate itself drawing
var points_to_draw: Array[Vector2]
## a variable that shows whether the line is currently in the process of drawing itself
var is_drawing: bool = false

## the end point of the currently animated segment, the position of which is 
## tweened
@onready var line_end_point = $LineEndPoint

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_drawing:
		#print("is drawing")
		points[0] = line_end_point.position
	#else:
		#print("is not drawing")

func draw_word(points_array: Array[Vector2]) -> void:
	if points_array.size() == 0:
		return
	add_point(points_array[0])
	_draw_segment(points_array)

func _draw_segment(points_array: Array[Vector2]) -> void:
	is_drawing = true
	add_point(points_array[0], 0)
	line_end_point.position = points_array[0]
	points_array.remove_at(0)
	
	if points_array.size() > 0:
		var distance: float = points_array[0].distance_to(points[0])
		var tweener: Tween = create_tween()
		tweener.tween_property(line_end_point, "position", points_array[0], 
				distance / animation_speed)
		var add_point_callable := \
				Callable(self, "_draw_segment").bind(points_array)
		tweener.tween_callback(add_point_callable)
	else: 
		finished_drawing.emit()
		is_drawing = false
