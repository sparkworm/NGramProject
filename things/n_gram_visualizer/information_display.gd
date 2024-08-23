class_name NGramInformationDisplay
extends Control

@export_category("Text boxes")
@export var vertices_count: Label
@export var lines_count: Label
@export var total_intersections_count: Label
@export var inside_intersections_count: Label
@export var outside_intersections_count: Label

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
