class_name NGramVisualizer
extends Node2D

enum DataTypes {
	VERTICES,
	LINES,
	TOTAL_INTERSECTION_POINTS,
	INSIDE_INTERSECTION_POINTS,
	OUTSIDE_INTERSECTION_POINTS,
}

#region export variables

@export var float_error_limit: float = 0.001
@export_group("Colors")
@export var line_color: Color
@export var point_color: Color
@export var intersection_point_on_line_color: Color
@export var intersection_point_outside_line_color: Color
@export var background_color: Color
@export_group("Scenes")
@export var point_scene: PackedScene
@export var line_scene: PackedScene
@export var intersection_point_scene: PackedScene

#endregion

#region variables

var points: Array[NGramPoint]
var intersection_points: Array[Polygon2D]
var lines: Array[NGramLine]
## a dictionary conataining data regarding the currently displayed n-gram
var n_gram_data: Dictionary = {
	DataTypes.VERTICES : 0,
	DataTypes.LINES : 0,
	DataTypes.TOTAL_INTERSECTION_POINTS : 0,
	DataTypes.INSIDE_INTERSECTION_POINTS : 0,
	DataTypes.OUTSIDE_INTERSECTION_POINTS : 0,
}

#endregion

#region onready variables

@onready var points_parent = $Points
@onready var lines_parent = $Lines
@onready var intersection_points_parent = $IntersectionPoints
@onready var n_gram_creation_ui:NGramCreationUI = \
		$CanvasLayer/NGramCreationUI
@onready var information_display_ui: NGramInformationDisplay = \
		$CanvasLayer/InformationDisplay

#endregion

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
	
	var fragment_lines_callable := \
			Callable(self, "fragment_all_lines")
	n_gram_creation_ui.fragment_lines_button_pressed.connect(\
			fragment_lines_callable)
	
	var count_polygons_callable := \
			Callable(self, "_count_possible_polygons")
	n_gram_creation_ui.count_polygons_button_pressed.connect(\
			count_polygons_callable)

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

#region Single NGram component creation

func add_point(pos: Vector2, connect_to_others=true) -> NGramPoint:
	var new_point: NGramPoint = point_scene.instantiate()
	new_point.position = pos
	new_point.modulate = point_color
	points_parent.add_child(new_point)
	points.append(new_point)
	if connect_to_others:
		_connect_new_point(new_point)
	n_gram_data[DataTypes.VERTICES] += 1
	_update_data(DataTypes.VERTICES)
	return new_point

func add_line(p1: NGramPoint, p2: NGramPoint) -> void:
	var new_line: NGramLine = line_scene.instantiate()
	new_line.init(p1, p2)
	new_line.modulate = line_color
	lines_parent.add_child(new_line)
	lines.append(new_line)
	n_gram_data[DataTypes.LINES] += 1
	_update_data(DataTypes.LINES)

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

#endregion

#region Single NGram component removal

func remove_point(point: NGramPoint) -> void:
	# remove all lines containing the point
	var lines_to_erase: Array[NGramLine] = []
	for line: NGramLine in lines:
		if line.has_point(point):
			lines_to_erase.append(line)
	
	for line: NGramLine in lines_to_erase:
		line.queue_free()
		lines.erase(line)
		n_gram_data[DataTypes.LINES] -= 1
	
	point.queue_free()
	points.erase(point)
	
	n_gram_data[DataTypes.VERTICES] -= 1
	_update_data(DataTypes.VERTICES)
	_update_data(DataTypes.LINES)

#endregion

#region Single NGram component manipulation

func _connect_new_point(new_point: NGramPoint) -> void:
	for point: NGramPoint in points:
		if point != new_point:
			add_line(point, new_point)

func fragment_line(line: NGramLine) -> bool:
	if line.points_on_line.size() <= 2:
		return false
	var points_array: Array[Vector2]
	#points_array.append_array([line.point0.position, line.point1.position])
	points_array.append_array(line.points_on_line)
	# might benefit from changing this to sort_custom
	var sort_callable := Callable(GlobalFunctions, "custom_sort_vec2")\
			.bind(float_error_limit)
	points_array.sort_custom(sort_callable)
	
	var previous_point: NGramPoint = null
	for point: Vector2 in points_array:
		var new_point := add_point(point, false)
		# going to perform a lot of unnecessary checks  :(
		if previous_point != null:
			add_line(previous_point, new_point)
		
		previous_point = new_point
	
	return true
	# gets rid of original line
	#lines.erase(line)
	#line.queue_free()

#endregion

#region Multiple Ngram component functions

func create_n_gram(point_num: int, radius: float) -> void:
	for p: int in range(0,point_num):
		var angle := Vector2.from_angle(p*(TAU/point_num))
		add_point(angle*radius)

func fragment_all_lines() -> void:
	# create new variable so that the fragments created don't cause an infinite
	# loop
	var lines_to_fragment: Array[NGramLine] = lines.duplicate(false)
	var lines_to_delete: Array[NGramLine] = []
	for line: NGramLine in lines_to_fragment:
		if fragment_line(line):
			lines_to_delete.append(line)
	
	for line in lines_to_delete:
		lines.erase(line)
		line.queue_free()
		n_gram_data[DataTypes.LINES] -= 1
		_update_data(DataTypes.LINES)

func place_line_intersection_points() -> void:
	clear_intersection_points()
	
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
				new_point.is_on_line = \
						l.is_point_on_line(new_point.position, \
						float_error_limit) && \
						unintersected.is_point_on_line(new_point.position, \
						float_error_limit)
				new_intersection_points.append(new_point)
	
	# remove array duplicates
	new_intersection_points.assign(\
			_intersection_point_array_unique(new_intersection_points))
	
	var num_points_on_line: int = 0
	for p: NGramIntersectionPoint in new_intersection_points:
		add_intersection_point(p)
		if p.is_on_line:
			num_points_on_line += 1
	
	n_gram_data[DataTypes.TOTAL_INTERSECTION_POINTS] = \
			new_intersection_points.size()
	n_gram_data[DataTypes.INSIDE_INTERSECTION_POINTS] = \
			num_points_on_line
	n_gram_data[DataTypes.OUTSIDE_INTERSECTION_POINTS] = \
			new_intersection_points.size() - num_points_on_line
	
	_update_data(DataTypes.TOTAL_INTERSECTION_POINTS)
	_update_data(DataTypes.INSIDE_INTERSECTION_POINTS)
	_update_data(DataTypes.OUTSIDE_INTERSECTION_POINTS)

func clear_intersection_points() -> void:
	for child: Node in intersection_points_parent.get_children():
		intersection_points_parent.remove_child(child)
		child.queue_free()
	intersection_points = []

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
	# NOTE: This is stupid
	n_gram_data[DataTypes.VERTICES] = 0
	n_gram_data[DataTypes.LINES] = 0
	n_gram_data[DataTypes.TOTAL_INTERSECTION_POINTS] = 0
	n_gram_data[DataTypes.INSIDE_INTERSECTION_POINTS] = 0
	n_gram_data[DataTypes.OUTSIDE_INTERSECTION_POINTS] = 0
	_update_data(DataTypes.VERTICES)
	_update_data(DataTypes.LINES)
	_update_data(DataTypes.TOTAL_INTERSECTION_POINTS)
	_update_data(DataTypes.INSIDE_INTERSECTION_POINTS)
	_update_data(DataTypes.OUTSIDE_INTERSECTION_POINTS)

#endregion

#region utility

func _intersection_point_array_unique(array: Array[NGramIntersectionPoint])\
		 -> Array[NGramIntersectionPoint]:
	var unique: Array[NGramIntersectionPoint] = []
	
	for item in array:
		var is_unique: bool = true
		for u: NGramIntersectionPoint in unique:
			# NOTE: can likely be improved by simply subtracting vectors and
			# taking length()
			var x_diff: float = abs(item.position.x - u.position.x)
			var y_diff: float = abs(item.position.y - u.position.y)
			if x_diff < float_error_limit and y_diff < float_error_limit:
				is_unique = false
				break;
		if is_unique:
			unique.append(item)
	
	return unique

func _update_data(data_type: DataTypes) -> void:
	information_display_ui.update_data(data_type, n_gram_data[data_type])

func _count_possible_polygons() -> int:
	var num_polygons: int = 0
	
	var lines_remaining: Array[LineData] = []
	for line: NGramLine in lines:
		lines_remaining.append(line.generate_line_data())
		#print(line.generate_line_data())
	
	print("Line data collected!\nNumber of lines: ", lines_remaining.size())
	
	var points_remaining: Array[Vector2] = []
	for point in points:
		points_remaining.append(point.position)
	points_remaining = GlobalFunctions.vector_array_unique(points_remaining, \
			float_error_limit)
	
	print("Point data collected!\nNumber of points: ", points_remaining.size())
	
	while points_remaining.size() > 2:
		print_rich("\n\n\n[color=white][b]New Iteration![/b][/color]")
		print("Points remaining: ", points_remaining)
		print("Lines remaining: ", lines_remaining)
		
		var point: Vector2 = points_remaining[0]
		print("This point: ", point)
		
		#var lines_with_point: Array[LineData] = \
				#_get_lines_with_point(lines_remaining, point)
		
		num_polygons += _recursive_polygon_trace(point, point, [], lines_remaining)
		print("Polygons counted: ", \
				_recursive_polygon_trace(point, point, [], lines_remaining))
		
		# erase the point from the array of available points
		points_remaining.erase(point)
		# erase all lines that contained the point
		var lines_to_erase := _get_lines_with_point(lines_remaining, point)
		for l in lines_to_erase:
			#print("Erasing line ", l)
			lines_remaining.erase(l)
		#print("Erasing complete")
	
	print("Polygons (twice answer): ", num_polygons)
	
	@warning_ignore("integer_division")
	return num_polygons / 2

func _recursive_polygon_trace(point: Vector2, target_point: Vector2, \
		blacklisted_points: Array[Vector2], all_lines: Array[LineData]) -> int:
	CustomIndent.increase_indent()
	print_rich(CustomIndent, "[color=cyan]ENTERING RECURSION[/color]")
	print_rich(CustomIndent, "Tracing [color=yellow]", blacklisted_points, 
			"[/color] to [color=magenta]", point, "[/color]")
	# the sum of polygons that can be created from this position
	var sum: int = 0
	# adds the current point to blacklisted points, but only if it is not the 
	# target point
	if not point == target_point:
		blacklisted_points.append(point)
	print_rich(CustomIndent, "Lines connected to point [color=magenta]", point, "[/color]: [color=orange]", \
			_get_lines_with_point(all_lines, point), "[/color]")
	for l in _get_lines_with_point(all_lines, point):
		# identifies the "other" point, which the the point on the given line
		# that is not the point that was originally specified.  
		# effectively, this allows checking points that are connected to the
		# specified point
		var other_point = l.other_point(point, float_error_limit)
		print_rich(CustomIndent, "\tOther point: [color=pink]", other_point, "[/color]")
		#print_rich("\tFrom line: [color=orange]", l, "[/color]")
		
		# if the point has not been blacklisted yet in this path (has not 
		# already been traveled over)
		#elif not blacklisted_points.has(other_point):
		if not GlobalFunctions.vector_array_has(blacklisted_points, \
				other_point, float_error_limit):
			print(CustomIndent, "\t\tNot blacklisted")
			# checks if the other point is the starting point
			if (target_point - other_point).length() < float_error_limit:
				# WARNING: make sure that this is the correct number
				# should only be entred if the number of points so far is high
				# enough for there to be a polygon (not simply a backstep)
				if blacklisted_points.size() > 1:
					sum += 1
					print_rich(CustomIndent, "[color=green]Polygon found: ", 
							blacklisted_points, other_point, "[/color]")
					#break
			else:
				# add the total number of polygons that can be made from the 
				# "other" point to the sum, which will be returned
				sum += _recursive_polygon_trace(other_point, target_point, \
						blacklisted_points, all_lines)
		else:
			print_rich(CustomIndent, "\t\t[b]BLACKLSTED[/b]")
	
	print_rich(CustomIndent, "[color=red]END OF RECURSION[/color]")
	CustomIndent.decrease_indent()
	return sum

func _get_connected_points(line_array: Array[LineData], p: Vector2) \
		-> Array[Vector2]:
	var new_points_array: Array[Vector2] = []
	for l in line_array:
		if l.has_point_within_error(p, float_error_limit):
			# append the point that isn't p
			new_points_array.append(l.other_point(p, float_error_limit))
	return new_points_array

func _get_lines_with_point(line_array: Array[LineData], p: Vector2) \
		-> Array[LineData]:
	var new_lines_array: Array[LineData] = []
	for l in line_array:
		if l.has_point_within_error(p, float_error_limit):
			new_lines_array.append(l)
	return new_lines_array

#endregion
