extends Node2D

@export var line_color: Color
@export var point_color: Color
@export var intersection_point_on_line_color: Color
@export var intersection_point_outside_line_color: Color
@export var background_color: Color
@export_category("Scenes")
@export var point_scene: PackedScene
@export var line_scene: PackedScene
@export var intersection_point_scene: PackedScene

var points: Array[NGramPoint]
var intersection_points: Array[Polygon2D]
var lines: Array[NGramLine]

@onready var points_parent = $Points
@onready var lines_parent = $Lines
@onready var intersection_points_parent = $IntersectionPoints
@onready var n_gram_creation_ui = $CanvasLayer/NGramCreationUI

func _ready() -> void:
	RenderingServer.set_default_clear_color(background_color)
	
	var create_n_gram_callable := Callable(self, "create_n_gram")
	n_gram_creation_ui.create_button_pressed.connect(create_n_gram_callable)
	
	var remove_all_points_callable := Callable(self, "remove_all_points")
	n_gram_creation_ui.clear_all_points.connect(remove_all_points_callable)
	
	var generate_intersection_points_callable := \
			Callable(self, "place_line_intersection_points")
	n_gram_creation_ui.generate_intersection_points.connect(\
			generate_intersection_points_callable)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		var point_hovered: NGramPoint = null
		
		for point: NGramPoint in points:
			if point.is_mouse_over:
				point_hovered = point
		
		if point_hovered != null:
			remove_point(point_hovered)
		else:
			add_point(get_global_mouse_position())

#region main structure

func add_point(pos: Vector2) -> void:
	var new_point: NGramPoint = point_scene.instantiate()
	new_point.position = pos
	new_point.modulate = point_color
	points_parent.add_child(new_point)
	points.append(new_point)
	connect_new_point(new_point)

func add_line(p1: NGramPoint, p2: NGramPoint) -> void:
	var new_line: NGramLine = line_scene.instantiate()
	new_line.init(p1, p2)
	new_line.modulate = line_color
	lines_parent.add_child(new_line)
	lines.append(new_line)

func connect_new_point(new_point: NGramPoint) -> void:
	for point: NGramPoint in points:
		if point != new_point:
			add_line(point, new_point)

func remove_point(point: NGramPoint) -> void:
	# remove all lines containing the point
	var lines_to_erase: Array[NGramLine] = []
	for line: NGramLine in lines:
		if line.has_point(point):
			lines_to_erase.append(line)
	
	for line: NGramLine in lines_to_erase:
		line.queue_free()
		lines.erase(line)
	
	point.queue_free()
	points.erase(point)

func remove_all_points() -> void:
	for child: Node in points_parent.get_children():
		points_parent.remove_child(child)
		child.queue_free()
	for child: Node in lines_parent.get_children():
		lines_parent.remove_child(child)
		child.queue_free()
	for child: Node in intersection_points_parent.get_children():
		intersection_points_parent.remove_child(child)
		child.queue_free()
	points = []
	lines = []
	intersection_points = []

func create_n_gram(point_num: int, radius: float) -> void:
	for p: int in range(0,point_num):
		var angle := Vector2.from_angle(p*(TAU/point_num))
		add_point(angle*radius)
	#place_line_intersection_points()

func add_intersection_point(point: NGramIntersectionPoint) -> void:
	var intersection_point: Polygon2D = intersection_point_scene.instantiate()
	intersection_point.position = point.position
	if point.is_on_line:
		intersection_point.modulate = intersection_point_on_line_color
	else:
		intersection_point.modulate = intersection_point_outside_line_color
		intersection_point.rotation = PI/4
	
	intersection_points_parent.add_child(intersection_point)
	intersection_points.append(intersection_point)

func _clear_intersection_points() -> void:
	for child: Node in intersection_points_parent.get_children():
		intersection_points_parent.remove_child(child)
		child.queue_free()
	intersection_points = []

func place_line_intersection_points() -> void:
	_clear_intersection_points()
	
	var unintersected_lines: Array = lines_parent.get_children()
	var new_intersection_points: Array[NGramIntersectionPoint]
	for l: NGramLine in lines_parent.get_children():
		# remove l from unintersected_lines so that it doesn't bother checking
		# itself, and so that future iterations won't check it
		unintersected_lines.erase(l)
		for unintersected: NGramLine in unintersected_lines:
			var intersection_location: Vector2 = \
					unintersected.get_point_of_intersection(l)
			if not intersection_location == Vector2.INF:
				var new_point := NGramIntersectionPoint.new()
				new_point.position = intersection_location
				new_point.is_on_line = l.is_point_on_line(new_point.position)
				new_intersection_points.append(new_point)
	
	#print(new_intersection_points, "\n\n")
	
	# remove array duplicates
	new_intersection_points.assign(\
			_intersection_point_array_unique(new_intersection_points))
	
	#new_intersection_points.sort()
	
	#for n in new_intersection_points:
		#print(n)
	
	print("\nsize: ", new_intersection_points.size())
	
	for p: NGramIntersectionPoint in new_intersection_points:
		add_intersection_point(p)
	

#endregion

func _intersection_point_array_unique(array: Array[NGramIntersectionPoint])\
		 -> Array[NGramIntersectionPoint]:
	var unique: Array[NGramIntersectionPoint] = []

	for item in array:
		var is_unique: bool = true
		for u: NGramIntersectionPoint in unique:
			if item.position.is_equal_approx(u.position):
				is_unique = false
				break;
		if is_unique:
			unique.append(item)
	
	return unique
