class_name NGramInformationDisplay
extends Control

@export_category("Text boxes")
@export var vertices_count: Label
@export var lines_count: Label
@export var total_intersections_count: Label
@export var inside_intersections_count: Label
@export var outside_intersections_count: Label

func update_data(data_type: NGramVisualizer.DataTypes, value: Variant) -> void:
	match(data_type):
		NGramVisualizer.DataTypes.VERTICES:
			update_vertices_count(value)
		NGramVisualizer.DataTypes.LINES:
			update_lines_count(value)
		NGramVisualizer.DataTypes.TOTAL_INTERSECTION_POINTS:
			update_total_intersections_count(value)
		NGramVisualizer.DataTypes.INSIDE_INTERSECTION_POINTS:
			update_inside_intersections_count(value)
		NGramVisualizer.DataTypes.OUTSIDE_INTERSECTION_POINTS:
			update_outside_intersections_count(value)
		_:
			print("unknown data type")

func update_vertices_count(new_value: int) -> void:
	vertices_count.text = str(new_value)

func update_lines_count(new_value: int) -> void:
	lines_count.text = str(new_value)

func update_total_intersections_count(new_value: int) -> void:
	total_intersections_count.text = str(new_value)

func update_inside_intersections_count(new_value: int) -> void:
	inside_intersections_count.text = str(new_value)

func update_outside_intersections_count(new_value: int) -> void:
	outside_intersections_count.text = str(new_value)
